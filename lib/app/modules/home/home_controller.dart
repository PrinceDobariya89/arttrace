import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/category_model.dart';
import '../../data/models/drawing_model.dart';
import '../../data/models/tutorial_model.dart';
import '../../data/repositories/drawing_repository.dart';
import '../../data/repositories/tutorial_repository.dart';
import '../../data/sample_data/sample_categories.dart';
import '../../routes/app_routes.dart';
import '../../services/storage/storage_service.dart';
import '../gallery/gallery_controller.dart';
import '../main_nav/main_nav_controller.dart';

class HomeController extends GetxController {
  final DrawingRepository _drawingRepo = Get.find<DrawingRepository>();
  final TutorialRepository _tutorialRepo = Get.find<TutorialRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController searchController = TextEditingController();

  final RxList<DrawingModel> featuredDrawings = <DrawingModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<DrawingModel> trendingDrawings = <DrawingModel>[].obs;
  final RxList<DrawingModel> recentDrawings = <DrawingModel>[].obs;
  final RxList<DrawingModel> premiumDrawings = <DrawingModel>[].obs;
  final RxList<DrawingTutorial> tutorials = <DrawingTutorial>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  void loadHomeData() {
    featuredDrawings.assignAll(_drawingRepo.getFeaturedDrawings());
    categories.assignAll(SampleCategories.categories);
    trendingDrawings.assignAll(_drawingRepo.getTrendingDrawings());
    recentDrawings.assignAll(_drawingRepo.getRecentlyViewed());
    premiumDrawings.assignAll(_drawingRepo.getPremiumDrawings());
    tutorials.assignAll(_tutorialRepo.getAllTutorials());
  }

  void onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;
    // Switch to Explore tab with search query
    try {
      final galleryController = Get.find<GalleryController>();
      galleryController.searchQuery.value = query;
      galleryController.searchController.text = query;
      galleryController.performSearch();
      Get.find<MainNavController>().changeTab(1);
    } catch (_) {
      Get.toNamed(Routes.gallery, arguments: {'query': query});
    }
  }

  void onCategorySelected(CategoryModel category) {
    try {
      final galleryController = Get.find<GalleryController>();
      galleryController.selectCategory(category.id);
      Get.find<MainNavController>().changeTab(1);
    } catch (_) {
      Get.toNamed(Routes.gallery, arguments: {'categoryId': category.id});
    }
  }

  void openDrawingDetail(DrawingModel drawing) {
    _storageService.addRecentDrawing(drawing.id);
    recentDrawings.assignAll(_drawingRepo.getRecentlyViewed());
    Get.toNamed(Routes.imageDetail, arguments: drawing);
  }

  void openTutorial(DrawingTutorial tutorial) {
    Get.toNamed(Routes.tutorialDetail, arguments: tutorial);
  }

  void openPremium() {
    Get.toNamed(Routes.premium);
  }

  Future<void> importCustomImage() async {
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
          title: 'My Custom Photo',
          categoryId: 'custom',
          categoryName: 'Custom Import',
          assetPath: image.path,
          isLocalFile: true,
          difficulty: DrawingDifficulty.intermediate,
          description: 'Imported from device gallery for AR tracing.',
        );

        Get.toNamed(Routes.tracing, arguments: customDrawing);
      }
    } catch (e) {
      debugPrint('Error picking custom image: $e');
    }
  }
}

