import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/utils/helpers.dart';
import '../../data/models/drawing_model.dart';
import '../../data/models/tutorial_model.dart';
import '../../routes/app_routes.dart';

class TutorialsController extends GetxController {
  late DrawingTutorial tutorial;
  final RxInt currentStepIndex = 0.obs;
  final TransformationController transformController =
      TransformationController();

  @override
  void onInit() {
    super.onInit();
    tutorial = Get.arguments as DrawingTutorial;
  }

  TutorialStep get currentStep => tutorial.steps[currentStepIndex.value];

  bool get isFirstStep => currentStepIndex.value == 0;
  bool get isLastStep => currentStepIndex.value == tutorial.steps.length - 1;

  void nextStep() {
    if (!isLastStep) {
      AppHelpers.hapticLight();
      currentStepIndex.value++;
      transformController.value = Matrix4.identity(); // Reset zoom
    }
  }

  void previousStep() {
    if (!isFirstStep) {
      AppHelpers.hapticLight();
      currentStepIndex.value--;
      transformController.value = Matrix4.identity(); // Reset zoom
    }
  }

  void jumpToStep(int index) {
    if (index >= 0 && index < tutorial.steps.length) {
      AppHelpers.hapticLight();
      currentStepIndex.value = index;
      transformController.value = Matrix4.identity();
    }
  }

  void traceCurrentStep() {
    // Construct a DrawingModel for the specific step so user can trace it directly in AR!
    final step = currentStep;
    final stepDrawing = DrawingModel(
      id: '${tutorial.drawingId}_step_${step.stepNumber}',
      title: '${tutorial.title} - Step ${step.stepNumber}',
      categoryId: 'tutorial',
      categoryName: tutorial.category,
      assetPath: step.imageAsset,
      isPremium: false,
      difficulty: DrawingDifficulty.beginner,
      description: step.instruction,
    );

    Get.toNamed(Routes.tracing, arguments: stepDrawing);
  }
}
