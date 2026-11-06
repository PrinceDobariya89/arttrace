import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/category_model.dart';
import '../../data/models/drawing_model.dart';
import '../../data/repositories/drawing_repository.dart';
import '../../data/sample_data/sample_categories.dart';
import '../../routes/app_routes.dart';
import '../../services/storage/storage_service.dart';

class GalleryController extends GetxController {
  final DrawingRepository _drawingRepo = Get.find<DrawingRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final TextEditingController searchController = TextEditingController();

  final RxString selectedCategory = 'all'.obs;
  final RxString selectedFilter = 'all'.obs; // 'all', 'free', 'premium'
  final RxString searchQuery = ''.obs;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<DrawingModel> displayedDrawings = <DrawingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    categories.assignAll([
      const CategoryModel(
        id: 'all',
        title: 'All Art',
        description: 'Browse all drawing categories',
        icon: Icons.grid_view_rounded,
      ),
      ...SampleCategories.categories,
    ]);

    // Check if initial arguments passed categoryId or query
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['categoryId'] != null) {
        selectedCategory.value = args['categoryId'] as String;
      }
      if (args['query'] != null) {
        searchQuery.value = args['query'] as String;
        searchController.text = searchQuery.value;
      }
    }

    performSearch();
  }

  void selectCategory(String catId) {
    selectedCategory.value = catId;
    performSearch();
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
    performSearch();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    performSearch();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    performSearch();
  }

  void performSearch() {
    List<DrawingModel> results = _drawingRepo.getAllDrawings();

    // 1. Category filter
    if (selectedCategory.value != 'all') {
      results = results
          .where((d) => d.categoryId.toLowerCase() == selectedCategory.value.toLowerCase())
          .toList();
    }

    // 2. Free / Premium filter
    if (selectedFilter.value == 'free') {
      results = results.where((d) => !d.isPremium).toList();
    } else if (selectedFilter.value == 'premium') {
      results = results.where((d) => d.isPremium).toList();
    }

    // 3. Search text
    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.toLowerCase().trim();
      results = results.where((d) {
        final inTitle = d.title.toLowerCase().contains(q);
        final inCat = d.categoryName.toLowerCase().contains(q);
        final inTags = d.tags.any((t) => t.toLowerCase().contains(q));
        return inTitle || inCat || inTags;
      }).toList();
    }

    displayedDrawings.assignAll(results);
  }

  void openDrawingDetail(DrawingModel drawing) {
    _storageService.addRecentDrawing(drawing.id);
    Get.toNamed(Routes.imageDetail, arguments: drawing);
  }
}

