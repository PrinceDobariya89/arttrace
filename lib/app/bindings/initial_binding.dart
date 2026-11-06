import 'package:get/get.dart';
import '../data/repositories/artwork_repository.dart';
import '../data/repositories/drawing_repository.dart';
import '../data/repositories/tutorial_repository.dart';
import '../services/ads/ad_service.dart';
import '../services/camera/camera_service.dart';
import '../services/purchases/purchase_service.dart';
import '../services/storage/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    final storageService = Get.find<StorageService>();
    Get.put<CameraService>(CameraService());
    Get.put<AdService>(AdService(storageService));
    Get.put<PurchaseService>(PurchaseService(storageService));

    // Repositories
    Get.put<DrawingRepository>(DrawingRepository(storageService));
    Get.put<TutorialRepository>(TutorialRepository());
    Get.put<ArtworkRepository>(ArtworkRepository(storageService));
  }
}

