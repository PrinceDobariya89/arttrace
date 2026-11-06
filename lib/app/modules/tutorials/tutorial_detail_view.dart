import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/banner_ad_widget.dart';
import '../../theme/app_colors.dart';
import 'tutorials_controller.dart';

class TutorialDetailView extends GetView<TutorialsController> {
  const TutorialDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final tut = controller.tutorial;

    return Scaffold(
      appBar: AppBar(
        title: Text(tut.title),
        actions: [
          Obx(
            () => Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'Step ${controller.currentStepIndex.value + 1}/${tut.steps.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Linear Progress Indicator
          Obx(() {
            final progress =
                (controller.currentStepIndex.value + 1) / tut.steps.length;
            return LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white12
                  : Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 4,
            );
          }),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Stage Navigation Chips
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: tut.steps.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return Obx(() {
                          final isCurrent =
                              controller.currentStepIndex.value == index;
                          return ChoiceChip(
                            label: Text('Stage ${index + 1}'),
                            selected: isCurrent,
                            onSelected: (_) => controller.jumpToStep(index),
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isCurrent ? Colors.white : null,
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Zoomable Stage Reference Canvas (InteractiveViewer)
                  Container(
                    width: double.infinity,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E202B)
                          : const Color(0xFFF1F3FA),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        InteractiveViewer(
                          transformationController:
                              controller.transformController,
                          minScale: 0.8,
                          maxScale: 4.0,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Obx(
                                () => Image.asset(
                                  controller.currentStep.imageAsset,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Pinch to zoom hint
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.zoom_in_rounded,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Pinch to Zoom',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Step Title & Instruction
                  Obx(
                    () => Text(
                      controller.currentStep.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => Text(
                      controller.currentStep.instruction,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pro Tip Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_rounded,
                          color: AppColors.warning,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Beginner Tip',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Obx(
                                () => Text(
                                  controller.currentStep.tip,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white70
                                        : Colors.black87,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Trace This Step in AR Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: controller.traceCurrentStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.camera_enhance_rounded),
                      label: const Text(
                        'Trace This Stage in AR Camera',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls (Previous / Next Buttons)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Previous Step Button
                    Obx(
                      () => Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.isFirstStep
                              ? null
                              : controller.previousStep,
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Previous'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Next Step Button
                    Obx(
                      () => Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.isLastStep
                              ? null
                              : controller.nextStep,
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                          label: Text(
                            controller.isLastStep ? 'Completed' : 'Next Stage',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Center(child: BannerAdWidget()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
