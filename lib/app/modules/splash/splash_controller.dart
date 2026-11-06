import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/storage/storage_service.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (_storageService.isFirstLaunch.value) {
      Get.offAllNamed(Routes.onboarding);
    } else {
      Get.offAllNamed(Routes.mainNav);
    }
  }
}

