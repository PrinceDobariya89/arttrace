import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/phone_stand_guide_dialog.dart';
import '../../theme/app_colors.dart';
import 'tracing_controller.dart';

class TracingView extends GetView<TracingController> {
  const TracingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Live Camera Preview Layer with RepaintBoundary for high-res snapshot
            RepaintBoundary(
              key: controller.repaintBoundaryKey,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Camera Layer
                  Obx(() {
                    if (!controller.isCameraReady.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (controller.cameraService.isSimulated.value ||
                        controller.cameraService.controller == null ||
                        !controller
                            .cameraService
                            .controller!
                            .value
                            .isInitialized) {
                      // Simulated desk / paper environment for emulator/simulator
                      return _buildSimulatedDeskPreview();
                    }

                    // Real Camera Preview
                    final cameraController =
                        controller.cameraService.controller!;
                    return ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width:
                                cameraController.value.previewSize?.height ??
                                1080,
                            height:
                                cameraController.value.previewSize?.width ??
                                1920,
                            child: CameraPreview(cameraController),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Transparent Drawing Overlay
                  _buildDrawingOverlay(context),
                ],
              ),
            ),

            // 2. Interactive Gesture Layer
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onScaleStart: controller.onScaleStart,
                onScaleUpdate: controller.onScaleUpdate,
                onTap: () {
                  // Tap on background to toggle distraction-free mode
                  controller.toggleControls();
                },
              ),
            ),

            // 3. UI Overlay Controls (distraction-free toggleable)
            Obx(
              () => AnimatedOpacity(
                opacity: controller.showControls.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: !controller.showControls.value,
                  child: Stack(
                    children: [
                      // Top Bar
                      _buildTopBar(context),

                      // Right Side Vertical Controls (Lock, Flash, Switch, Reset, Flip, Filter)
                      _buildRightToolBar(context),

                      // Bottom Panel (Opacity Slider & Presets & Capture Button)
                      _buildBottomPanel(context),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Lock Status Indicator Banner (shown when locked even if controls are hidden)
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Obx(() {
                if (!controller.isLocked.value) return const SizedBox.shrink();
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Canvas Locked for Tracing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: controller.toggleLock,
                          child: const Text(
                            'UNLOCK',
                            style: TextStyle(
                              color: Colors.yellowAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawingOverlay(BuildContext context) {
    return Obx(() {
      final drawing = controller.drawing;
      final colorFilter = controller.getColorFilter();

      Widget imageWidget;
      if (drawing.isLocalFile) {
        imageWidget = Image.file(File(drawing.assetPath), fit: BoxFit.contain);
      } else {
        imageWidget = Image.asset(drawing.assetPath, fit: BoxFit.contain);
      }

      if (colorFilter != null) {
        imageWidget = ColorFiltered(
          colorFilter: colorFilter,
          child: imageWidget,
        );
      }

      return Center(
        child: Transform.translate(
          offset: controller.position.value,
          child: Transform.rotate(
            angle: controller.rotation.value,
            child: Transform.scale(
              scale: controller.scale.value,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(
                  controller.isFlippedHorizontally.value ? math.pi : 0,
                ),
                child: Opacity(
                  opacity: controller.opacity.value,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: controller.isLocked.value
                        ? null
                        : BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                    child: imageWidget,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Back Button
          _buildCircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Get.back(),
            tooltip: 'Exit Tracing',
          ),
          const SizedBox(width: 10),

          // Title Chip
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 0.8),
              ),
              child: Text(
                controller.drawing.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Setup Guide Help Button
          _buildCircleButton(
            icon: Icons.help_outline_rounded,
            onTap: () {
              PhoneStandGuideDialog.showIfNeeded(context, onProceed: () {});
            },
            tooltip: 'Stand Setup Guide',
          ),
          const SizedBox(width: 8),

          // Hide / Distraction Free Button
          _buildCircleButton(
            icon: Icons.visibility_off_rounded,
            onTap: controller.toggleControls,
            tooltip: 'Hide Controls',
          ),
        ],
      ),
    );
  }

  Widget _buildRightToolBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 70,
      right: 16,
      child: Column(
        children: [
          // Lock / Unlock Image
          Obx(
            () => _buildToolButton(
              icon: controller.isLocked.value
                  ? Icons.lock_rounded
                  : Icons.lock_open_rounded,
              label: controller.isLocked.value ? 'Locked' : 'Lock',
              isActive: controller.isLocked.value,
              activeColor: Colors.redAccent,
              onTap: controller.toggleLock,
            ),
          ),
          const SizedBox(height: 12),

          // Flashlight / Torch
          Obx(
            () => _buildToolButton(
              icon: controller.cameraService.isTorchOn.value
                  ? Icons.flashlight_on_rounded
                  : Icons.flashlight_off_rounded,
              label: 'Flash',
              isActive: controller.cameraService.isTorchOn.value,
              activeColor: Colors.amber,
              onTap: controller.cameraService.toggleTorch,
            ),
          ),
          const SizedBox(height: 12),

          // Switch Camera
          // _buildToolButton(
          //   icon: Icons.flip_camera_ios_rounded,
          //   label: 'Switch',
          //   onTap: controller.cameraService.switchCamera,
          // ),
          // const SizedBox(height: 12),

          // Flip Horizontal
          Obx(
            () => _buildToolButton(
              icon: Icons.flip_rounded,
              label: 'Mirror',
              isActive: controller.isFlippedHorizontally.value,
              onTap: controller.toggleFlip,
            ),
          ),
          const SizedBox(height: 12),

          // Reset Position & Scale
          _buildToolButton(
            icon: Icons.restart_alt_rounded,
            label: 'Reset',
            onTap: controller.resetTransform,
          ),
          const SizedBox(height: 12),

          // Filter line colors (Normal, Invert, Color)
          _buildFilterButton(context),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Opacity Header & Presets
            Row(
              children: [
                const Icon(
                  Icons.opacity_rounded,
                  size: 18,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Obx(
                  () => Text(
                    'Opacity: ${(controller.opacity.value * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                // Presets 25%, 50%, 75%, 100%
                _buildOpacityPreset('25%', 0.25),
                const SizedBox(width: 6),
                _buildOpacityPreset('50%', 0.50),
                const SizedBox(width: 6),
                _buildOpacityPreset('75%', 0.75),
                const SizedBox(width: 6),
                _buildOpacityPreset('100%', 1.00),
              ],
            ),
            const SizedBox(height: 6),

            // Opacity Slider
            Obx(
              () => SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primaryLight,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                  overlayColor: AppColors.primary.withValues(alpha: 0.2),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 9,
                  ),
                ),
                child: Slider(
                  value: controller.opacity.value,
                  min: 0.05,
                  max: 1.0,
                  onChanged: controller.setOpacity,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Capture Snapshot Row
            Row(
              children: [
                // Zoom minus button
                _buildZoomButton(Icons.remove_rounded, () {
                  final newScale = (controller.scale.value - 0.15).clamp(
                    0.2,
                    5.0,
                  );
                  controller.scale.value = newScale;
                }),
                const SizedBox(width: 8),
                Obx(
                  () => Text(
                    '${(controller.scale.value * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                // Zoom plus button
                _buildZoomButton(Icons.add_rounded, () {
                  final newScale = (controller.scale.value + 0.15).clamp(
                    0.2,
                    5.0,
                  );
                  controller.scale.value = newScale;
                }),

                const Spacer(),

                // Center Capture Screenshot Button
                ElevatedButton.icon(
                  onPressed: controller.captureScreenshot,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt_rounded, size: 20),
                  label: const Text(
                    'Capture & Save',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpacityPreset(String label, double val) {
    return Obx(() {
      final isCurrent = (controller.opacity.value - val).abs() < 0.05;
      return GestureDetector(
        onTap: () => controller.setOpacity(val),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.primary : Colors.white12,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isCurrent ? Colors.white : Colors.white70,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white12,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 0.8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color activeColor = AppColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? Colors.white : Colors.white24,
            width: 0.8,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return PopupMenuButton<TracingLineFilter>(
      onSelected: controller.setFilter,
      color: const Color(0xFF232530),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: TracingLineFilter.normal,
          child: Text(
            'Original Black Lines',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const PopupMenuItem(
          value: TracingLineFilter.inverted,
          child: Text(
            'Inverted White Lines',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const PopupMenuItem(
          value: TracingLineFilter.red,
          child: Text(
            'Red Line Tint',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
        const PopupMenuItem(
          value: TracingLineFilter.blue,
          child: Text(
            'Blue Line Tint',
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
        const PopupMenuItem(
          value: TracingLineFilter.green,
          child: Text(
            'Neon Green Tint',
            style: TextStyle(color: Colors.greenAccent),
          ),
        ),
      ],
      child: Container(
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, width: 0.8),
        ),
        child: Column(
          children: const [
            Icon(Icons.palette_rounded, color: Colors.white, size: 22),
            SizedBox(height: 3),
            Text(
              'Color',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulatedDeskPreview() {
    return Container(
      color: const Color(0xFFE5DDD5),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Simulated desk wood/paper texture grid
          CustomPaint(painter: _DeskPaperGridPainter()),
          Positioned(
            top: 100,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Camera Preview (Simulated Desk & Paper)\nReady to trace: place your phone over blank paper.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeskPaperGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw subtle sketch paper grid
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    const step = 25.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Sheet of paper outline
    final paperRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.88,
      height: size.height * 0.75,
    );

    final paperPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(paperRect, const Radius.circular(8)),
      paperPaint,
    );

    final borderPaint = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(paperRect, const Radius.circular(8)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
