import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../common/utils/helpers.dart';
import '../../data/models/artwork_model.dart';
import '../../data/models/drawing_model.dart';
import '../../data/repositories/artwork_repository.dart';
import '../../services/camera/camera_service.dart';
import '../../services/storage/storage_service.dart';

enum TracingLineFilter { normal, inverted, red, blue, green }

class TracingController extends GetxController with WidgetsBindingObserver {
  final CameraService cameraService = Get.find<CameraService>();
  final StorageService storageService = Get.find<StorageService>();
  final ArtworkRepository artworkRepo = Get.find<ArtworkRepository>();

  late DrawingModel drawing;

  final GlobalKey repaintBoundaryKey = GlobalKey();

  // AR Overlay Transformation States
  final RxDouble opacity = 0.65.obs;
  final RxDouble scale = 1.0.obs;
  final RxDouble rotation = 0.0.obs; // In radians
  final Rx<Offset> position = Offset.zero.obs;
  final RxBool isLocked = false.obs;
  final RxBool isFlippedHorizontally = false.obs;
  final Rx<TracingLineFilter> activeFilter = TracingLineFilter.normal.obs;

  // UI Visibility States
  final RxBool showControls = true.obs;
  final RxBool isCapturing = false.obs;
  final RxBool isCameraReady = false.obs;
  final RxString statusMessage = ''.obs;

  // Gesture tracking base values
  double _baseScale = 1.0;
  double _baseRotation = 0.0;
  Offset _basePosition = Offset.zero;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    drawing = Get.arguments as DrawingModel;
    opacity.value = storageService.defaultOpacity.value;

    initCamera();
  }

  Future<void> initCamera() async {
    isCameraReady.value = false;
    final success = await cameraService.initializeController();
    isCameraReady.value = success;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      cameraService.disposeController();
      isCameraReady.value = false;
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  // Transformation Gestures
  void onScaleStart(ScaleStartDetails details) {
    if (isLocked.value) return;
    _baseScale = scale.value;
    _baseRotation = rotation.value;
    _basePosition = position.value;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (isLocked.value) return;

    // Translation (Pan/Drag)
    position.value = _basePosition + details.focalPointDelta;
    _basePosition = position.value;

    // Scale (Pinch zoom)
    if (details.scale != 1.0) {
      scale.value = (_baseScale * details.scale).clamp(0.2, 5.0);
    }

    // Rotation (Two fingers)
    if (details.rotation != 0.0) {
      rotation.value = _baseRotation + details.rotation;
    }
  }

  void resetTransform() {
    AppHelpers.hapticLight();
    scale.value = 1.0;
    rotation.value = 0.0;
    position.value = Offset.zero;
    isFlippedHorizontally.value = false;
  }

  void toggleLock() {
    AppHelpers.hapticLight();
    isLocked.toggle();
    if (isLocked.value) {
      AppHelpers.showInfoSnackbar(
        'Canvas Locked',
        'Image position is fixed for steady paper tracing.',
      );
    } else {
      AppHelpers.showInfoSnackbar(
        'Canvas Unlocked',
        'You can now drag, zoom, and rotate the image.',
      );
    }
  }

  void toggleFlip() {
    AppHelpers.hapticLight();
    isFlippedHorizontally.toggle();
  }

  void setOpacity(double val) {
    opacity.value = val.clamp(0.0, 1.0);
    storageService.setDefaultOpacity(opacity.value);
  }

  void toggleControls() {
    showControls.toggle();
  }

  void setFilter(TracingLineFilter filter) {
    AppHelpers.hapticLight();
    activeFilter.value = filter;
  }

  ColorFilter? getColorFilter() {
    switch (activeFilter.value) {
      case TracingLineFilter.normal:
        return null;
      case TracingLineFilter.inverted:
        // Inverts black lines to white lines
        return const ColorFilter.matrix([
          -1,
          0,
          0,
          0,
          255,
          0,
          -1,
          0,
          0,
          255,
          0,
          0,
          -1,
          0,
          255,
          0,
          0,
          0,
          1,
          0,
        ]);
      case TracingLineFilter.red:
        return const ColorFilter.mode(Colors.redAccent, BlendMode.srcIn);
      case TracingLineFilter.blue:
        return const ColorFilter.mode(Colors.blueAccent, BlendMode.srcIn);
      case TracingLineFilter.green:
        return const ColorFilter.mode(Colors.greenAccent, BlendMode.srcIn);
    }
  }

  Future<void> captureScreenshot() async {
    try {
      isCapturing.value = true;
      AppHelpers.hapticMedium();

      // Ensure boundary is rendered
      await Future.delayed(const Duration(milliseconds: 100));

      final RenderRepaintBoundary? boundary =
          repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        AppHelpers.showErrorSnackbar(
          'Capture Failed',
          'Could not locate view boundary.',
        );
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        AppHelpers.showErrorSnackbar('Capture Failed', 'Image encoding error.');
        return;
      }

      final bytes = byteData.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final artworkDir = Directory('${directory.path}/artworks');
      if (!artworkDir.existsSync()) {
        artworkDir.createSync(recursive: true);
      }

      final fileName = 'trace_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${artworkDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Save artwork record in repository
      final newArtwork = ArtworkModel(
        id: 'art_${DateTime.now().millisecondsSinceEpoch}',
        title: '${drawing.title} Trace',
        filePath: file.path,
        originalDrawingId: drawing.id,
        category: drawing.categoryName,
        createdAt: DateTime.now(),
      );
      artworkRepo.saveArtwork(newArtwork);

      // Show dialog with preview & share options
      _showCaptureSuccessDialog(file.path, newArtwork);
    } catch (e) {
      debugPrint('Error capturing screenshot: $e');
      AppHelpers.showErrorSnackbar('Error', 'Failed to save tracing photo: $e');
    } finally {
      isCapturing.value = false;
    }
  }

  void _showCaptureSuccessDialog(String filePath, ArtworkModel artwork) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Drawing Saved!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.black12,
                  child: Image.file(File(filePath), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your tracing artwork was saved to My Art.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        SharePlus.instance.share(
                          ShareParams(
                            files: [XFile(filePath)],
                            text:
                                'Check out my AR trace drawing of ${drawing.title}!',
                          ),
                        );
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Keep Tracing'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    // Completely shut down and dispose camera when leaving tracing screen
    cameraService.disposeController();
    super.onClose();
  }
}
