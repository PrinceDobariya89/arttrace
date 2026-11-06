import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/utils/helpers.dart';
import '../../common/widgets/phone_stand_guide_dialog.dart';
import '../../data/models/drawing_model.dart';
import '../../data/models/tutorial_model.dart';
import '../../data/repositories/drawing_repository.dart';
import '../../data/repositories/tutorial_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/ads/ad_service.dart';
import '../../services/storage/storage_service.dart';

class ImageDetailController extends GetxController {
  final DrawingRepository _drawingRepo = Get.find<DrawingRepository>();
  final TutorialRepository _tutorialRepo = Get.find<TutorialRepository>();
  final StorageService storageService = Get.find<StorageService>();
  final AdService _adService = Get.find<AdService>();

  late DrawingModel drawing;
  final RxBool isFav = false.obs;
  final RxList<DrawingModel> similarDrawings = <DrawingModel>[].obs;
  DrawingTutorial? tutorial;

  @override
  void onInit() {
    super.onInit();
    drawing = Get.arguments as DrawingModel;
    isFav.value = storageService.isFavorite(drawing.id);
    tutorial = _tutorialRepo.getTutorialForDrawing(drawing.id);

    // Load similar drawings
    final sameCategory = _drawingRepo.getDrawingsByCategory(drawing.categoryId);
    similarDrawings.assignAll(
      sameCategory.where((d) => d.id != drawing.id).take(4).toList(),
    );
  }

  void toggleFavorite() {
    AppHelpers.hapticLight();
    storageService.toggleFavorite(drawing.id);
    isFav.value = storageService.isFavorite(drawing.id);
  }

  void startTracing(BuildContext context) {
    if (drawing.isPremium && !storageService.isPremium.value) {
      // Prompt rewarded ad or pro subscription
      _showUnlockDialog(context);
      return;
    }

    _proceedToTracing(context);
  }

  void _proceedToTracing(BuildContext context) {
    PhoneStandGuideDialog.showIfNeeded(
      context,
      onProceed: () {
        Get.toNamed(Routes.tracing, arguments: drawing);
      },
    );
  }

  void openTutorial() {
    if (tutorial != null) {
      Get.toNamed(Routes.tutorialDetail, arguments: tutorial);
    }
  }

  void _showUnlockDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.workspace_premium_rounded,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            const Text(
              'PRO Sketch Template',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'This exclusive artwork is part of our PRO collection. Choose how you would like to unlock it:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  Get.toNamed(Routes.premium);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text(
                  'Upgrade to PRO (Unlimited Access)',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.back();
                  _adService.showRewardedAd(
                    onUserEarnedReward: (_) {
                      AppHelpers.showSuccessSnackbar(
                        'Artwork Unlocked',
                        'Enjoy your drawing session!',
                      );
                      _proceedToTracing(context);
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.play_circle_fill_rounded),
                label: const Text('Watch 1 Ad to Unlock Once'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
