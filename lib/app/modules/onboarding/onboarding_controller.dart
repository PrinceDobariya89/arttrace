import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/camera/camera_service.dart';
import '../../services/storage/storage_service.dart';

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final String imageAsset;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.imageAsset,
  });
}

class OnboardingController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final CameraService _cameraService = Get.find<CameraService>();

  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<OnboardingStep> steps = const [
    OnboardingStep(
      title: 'Pick Any Sketch or Photo',
      description: 'Choose from hundreds of anime, cartoon, animal sketches, or import any photo directly from your phone gallery.',
      icon: Icons.palette_rounded,
      imageAsset: 'assets/drawings/anime_girl_eye.png',
    ),
    OnboardingStep(
      title: 'Elevate Phone Over Paper',
      description: 'Place your phone on a glass mug, cup, or desk stand about 20–30 cm directly above your blank sheet of paper.',
      icon: Icons.stay_current_portrait_rounded,
      imageAsset: 'assets/drawings/flower_rose.png',
    ),
    OnboardingStep(
      title: 'Look & Trace in Real Time',
      description: 'Look through your screen at the transparent outline projected on paper, and trace smoothly with your real pencil!',
      icon: Icons.draw_rounded,
      imageAsset: 'assets/drawings/cartoon_puppy.png',
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void next() {
    if (currentPage.value < steps.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      finishOnboarding();
    }
  }

  Future<void> finishOnboarding() async {
    // Proactively request camera permission for seamless AR experience
    await _cameraService.requestCameraPermission();
    _storageService.completeOnboarding();
    Get.offAllNamed(Routes.mainNav);
  }
}

