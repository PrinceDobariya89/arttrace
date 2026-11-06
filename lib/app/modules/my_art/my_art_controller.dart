import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../common/utils/helpers.dart';
import '../../data/models/artwork_model.dart';
import '../../data/models/drawing_model.dart';
import '../../data/repositories/artwork_repository.dart';
import '../../data/repositories/drawing_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/storage/storage_service.dart';

class MyArtController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ArtworkRepository _artworkRepo = Get.find<ArtworkRepository>();
  final DrawingRepository _drawingRepo = Get.find<DrawingRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();

  late TabController tabController;
  final RxInt currentTabIndex = 0.obs;

  final RxList<ArtworkModel> savedArtworks = <ArtworkModel>[].obs;
  final RxList<DrawingModel> favoriteDrawings = <DrawingModel>[].obs;
  final RxList<DrawingModel> recentDrawings = <DrawingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      if (currentTabIndex.value != tabController.index) {
        currentTabIndex.value = tabController.index;
        loadData();
      }
    });

    loadData();

    // Automatically react to changes in favorites and recent drawings
    ever(_storageService.favorites, (_) => loadData());
    ever(_storageService.recentDrawings, (_) => loadData());
  }

  void loadData() {
    savedArtworks.assignAll(_artworkRepo.getAllArtworks());
    favoriteDrawings.assignAll(_drawingRepo.getFavorites());
    recentDrawings.assignAll(_drawingRepo.getRecentlyViewed());
  }

  void shareArtwork(ArtworkModel artwork) {
    AppHelpers.hapticLight();
    SharePlus.instance.share(
      ShareParams(
        files: [XFile(artwork.filePath)],
        text: 'Look at my drawing made with ArtTrace AR!',
      ),
    );
  }

  void deleteArtwork(ArtworkModel artwork) {
    Get.defaultDialog(
      title: 'Delete Drawing',
      middleText: 'Are you sure you want to delete "${artwork.title}"?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        AppHelpers.hapticMedium();
        _artworkRepo.deleteArtwork(artwork.id);
        savedArtworks.assignAll(_artworkRepo.getAllArtworks());
        Get.back();
        AppHelpers.showSuccessSnackbar('Deleted', 'Drawing was removed.');
      },
    );
  }

  Future<void> openDrawingDetail(DrawingModel drawing) async {
    await Get.toNamed(Routes.imageDetail, arguments: drawing);
    loadData();
  }

  Future<void> importAndTraceCustomImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (image != null) {
        final customDrawing = DrawingModel(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Custom Gallery Photo',
          categoryId: 'custom',
          categoryName: 'Custom Import',
          assetPath: image.path,
          isLocalFile: true,
          difficulty: DrawingDifficulty.intermediate,
          description: 'Imported from device gallery for AR tracing.',
        );

        await Get.toNamed(Routes.tracing, arguments: customDrawing);
        loadData();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
