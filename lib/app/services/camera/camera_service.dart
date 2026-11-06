import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService extends GetxService {
  List<CameraDescription> cameras = [];
  CameraController? controller;

  final RxBool isInitialized = false.obs;
  final RxBool hasPermission = false.obs;
  final RxBool isTorchOn = false.obs;
  final RxBool isFrontCamera = false.obs;
  final RxBool isSimulated = false.obs;
  final RxDouble currentZoom = 1.0.obs;
  final RxDouble minZoom = 1.0.obs;
  final RxDouble maxZoom = 5.0.obs;
  final RxString errorMessage = ''.obs;

  int _selectedCameraIndex = 0;

  Future<CameraService> init() async {
    await checkPermissionAndInitCameras();
    return this;
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    hasPermission.value = status.isGranted;
    return status.isGranted;
  }

  Future<void> checkPermissionAndInitCameras() async {
    try {
      final status = await Permission.camera.status;
      hasPermission.value = status.isGranted;

      try {
        cameras = await availableCameras();
      } catch (e) {
        debugPrint('availableCameras error: $e');
        cameras = [];
      }

      if (cameras.isEmpty) {
        // Fallback for emulator / simulator / desktop
        isSimulated.value = true;
      }
    } catch (e) {
      debugPrint('Error inspecting camera environment: $e');
      isSimulated.value = true;
    }
  }

  Future<bool> initializeController() async {
    errorMessage.value = '';
    final perm = await Permission.camera.status;
    if (!perm.isGranted) {
      final granted = await requestCameraPermission();
      if (!granted) {
        errorMessage.value = 'Camera permission was denied. Please allow camera access in Settings.';
        isInitialized.value = false;
        return false;
      }
    }

    if (cameras.isEmpty) {
      try {
        cameras = await availableCameras();
      } catch (e) {
        cameras = [];
      }
    }

    if (cameras.isEmpty) {
      isSimulated.value = true;
      isInitialized.value = true;
      return true;
    }

    // Default to rear back camera for paper tracing
    _selectedCameraIndex = cameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );
    if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;

    return await _setupControllerWithCamera(cameras[_selectedCameraIndex]);
  }

  Future<bool> _setupControllerWithCamera(CameraDescription description) async {
    await controller?.dispose();
    controller = null;
    isInitialized.value = false;

    try {
      final newController = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await newController.initialize();
      controller = newController;
      isFrontCamera.value = description.lensDirection == CameraLensDirection.front;
      isTorchOn.value = false;

      try {
        minZoom.value = await newController.getMinZoomLevel();
        maxZoom.value = (await newController.getMaxZoomLevel()).clamp(1.0, 6.0);
        currentZoom.value = minZoom.value;
      } catch (_) {
        minZoom.value = 1.0;
        maxZoom.value = 4.0;
      }

      isSimulated.value = false;
      isInitialized.value = true;
      return true;
    } catch (e) {
      debugPrint('Error initializing camera controller: $e');
      errorMessage.value = 'Could not start camera preview: $e';
      // Gracefully fallback to simulated desk surface
      isSimulated.value = true;
      isInitialized.value = true;
      return true;
    }
  }

  Future<void> toggleTorch() async {
    if (controller == null || !controller!.value.isInitialized || isSimulated.value) {
      isTorchOn.toggle();
      return;
    }

    try {
      if (isTorchOn.value) {
        await controller!.setFlashMode(FlashMode.off);
        isTorchOn.value = false;
      } else {
        await controller!.setFlashMode(FlashMode.torch);
        isTorchOn.value = true;
      }
    } catch (e) {
      debugPrint('Torch error: $e');
    }
  }

  Future<void> switchCamera() async {
    if (cameras.length < 2 || isSimulated.value) {
      isFrontCamera.toggle();
      return;
    }

    _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras.length;
    await _setupControllerWithCamera(cameras[_selectedCameraIndex]);
  }

  Future<void> setZoom(double zoom) async {
    if (controller == null || !controller!.value.isInitialized || isSimulated.value) {
      currentZoom.value = zoom;
      return;
    }

    try {
      final clamped = zoom.clamp(minZoom.value, maxZoom.value);
      await controller!.setZoomLevel(clamped);
      currentZoom.value = clamped;
    } catch (e) {
      debugPrint('Zoom error: $e');
    }
  }

  Future<XFile?> takePicture() async {
    if (controller == null || !controller!.value.isInitialized || isSimulated.value) {
      return null;
    }

    try {
      return await controller!.takePicture();
    } catch (e) {
      debugPrint('Take picture error: $e');
      return null;
    }
  }

  Future<void> disposeController() async {
    try {
      if (isTorchOn.value && controller != null && controller!.value.isInitialized) {
        await controller!.setFlashMode(FlashMode.off);
        isTorchOn.value = false;
      }
      await controller?.dispose();
    } catch (e) {
      debugPrint('Error disposing camera controller: $e');
    } finally {
      controller = null;
      isInitialized.value = false;
    }
  }

  @override
  void onClose() {
    disposeController();
    super.onClose();
  }
}

