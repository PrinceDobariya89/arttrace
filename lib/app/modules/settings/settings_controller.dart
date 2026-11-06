import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../common/utils/helpers.dart';
import '../../routes/app_routes.dart';
import '../../services/purchases/purchase_service.dart';
import '../../services/storage/storage_service.dart';

class SettingsController extends GetxController {
  final StorageService storageService = Get.find<StorageService>();
  final PurchaseService purchaseService = Get.find<PurchaseService>();

  final RxString currentTheme = 'system'.obs;
  final RxBool hapticEnabled = true.obs;
  final RxDouble defaultOpacity = 0.65.obs;

  @override
  void onInit() {
    super.onInit();
    currentTheme.value = storageService.themeMode.value;
    hapticEnabled.value = storageService.hapticFeedback.value;
    defaultOpacity.value = storageService.defaultOpacity.value;
  }

  void setTheme(String mode) {
    AppHelpers.hapticLight();
    currentTheme.value = mode;
    storageService.setThemeMode(mode);

    if (mode == 'light') {
      Get.changeThemeMode(ThemeMode.light);
    } else if (mode == 'dark') {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.system);
    }
  }

  void toggleHaptic(bool val) {
    hapticEnabled.value = val;
    storageService.setHapticFeedback(val);
    if (val) AppHelpers.hapticMedium();
  }

  void setDefaultOpacity(double val) {
    defaultOpacity.value = val;
    storageService.setDefaultOpacity(val);
  }

  void resetStandGuide() {
    AppHelpers.hapticLight();
    storageService.setShowStandGuide(true);
    AppHelpers.showSuccessSnackbar(
      'Reset',
      'Phone stand instructions will show next time you trace.',
    );
  }

  void restorePurchases() {
    AppHelpers.hapticLight();
    purchaseService.restorePurchases();
    AppHelpers.showInfoSnackbar(
      'Restoring Purchases',
      'Checking Google Play billing account for active subscriptions...',
    );
  }

  void shareApp() {
    AppHelpers.hapticLight();
    SharePlus.instance.share(
      ShareParams(
        text:
            'Download ArtTrace: AR Drawing & Tracing! Easily draw anime, cartoons, and sketches by projecting them directly onto paper with your camera! 🎨✨\nhttps://play.google.com/store/apps/details?id=com.example.arttrace',
      ),
    );
  }

  void rateApp() {
    AppHelpers.hapticLight();
    Get.defaultDialog(
      title: 'Rate ArtTrace',
      middleText:
          'Enjoying ArtTrace? Leaving a 5-star review helps us add more anime and drawing sketches for everyone!',
      textConfirm: 'Rate 5 Stars ⭐',
      textCancel: 'Maybe Later',
      confirmTextColor: Colors.white,
      buttonColor: Colors.amber,
      onConfirm: () {
        Get.back();
        AppHelpers.showSuccessSnackbar(
          'Thank You!',
          'Thank you for supporting our indie development team!',
        );
      },
    );
  }

  void openPrivacyPolicy() {
    Get.defaultDialog(
      title: 'Privacy Policy',
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'ArtTrace Camera & Drawing Privacy',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                '1. Camera Access: ArtTrace uses your camera solely to project real-time transparent overlays on paper. No camera video is uploaded to any remote server.\n\n'
                '2. Saved Artwork: Snapshots you capture are stored purely on your local device.\n\n'
                '3. Monetization: Non-personalized Google AdMob ads are displayed to keep the app free. Pro users enjoy zero ads.\n\n'
                '4. In-App Purchases: Google Play handles all transaction billing securely.',
                style: TextStyle(fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ),
      textConfirm: 'I Understand',
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  void openPremium() {
    Get.toNamed(Routes.premium);
  }
}
