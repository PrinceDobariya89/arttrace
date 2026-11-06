import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/utils/helpers.dart';
import '../../data/models/drawing_model.dart';
import '../../data/models/web_image_model.dart';
import '../../routes/app_routes.dart';
import '../../services/storage/storage_service.dart';
import '../../services/web_image/web_image_service.dart';

class WebExplorerController extends GetxController {
  final WebImageService _webImageService = WebImageService();
  final StorageService _storageService = Get.find<StorageService>();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController urlController = TextEditingController();

  final RxInt activeTab = 0.obs; // 0 = Browse Images, 1 = Direct URL
  final RxString selectedCategory = 'All'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isDownloading = false.obs;
  final RxString downloadingTitle = ''.obs;

  final RxList<WebImageModel> searchResults = <WebImageModel>[].obs;

  final List<String> categories = const [
    'All',
    'Anime',
    'Animals',
    'Flowers',
    'Tattoo',
    'Cartoon',
    'Vehicles',
    'Architecture',
  ];

  @override
  void onInit() {
    super.onInit();
    final initialQuery = Get.arguments as String?;
    if (initialQuery != null && initialQuery.isNotEmpty) {
      searchController.text = initialQuery;
    }
    performSearch();
  }

  @override
  void onClose() {
    searchController.dispose();
    urlController.dispose();
    super.onClose();
  }

  void findDraw([String? customKeyword]) {
    final keyword = (customKeyword ?? searchController.text).trim();
    if (keyword.isEmpty) {
      AppHelpers.showInfoSnackbar(
        'Enter Keyword',
        'Please enter a keyword to find drawing ideas on Google.',
      );
      return;
    }
    AppHelpers.hapticLight();
    Get.toNamed(Routes.googleBrowser, arguments: keyword);
  }

  void selectCategory(String cat) {
    if (selectedCategory.value != cat) {
      AppHelpers.hapticLight();
      selectedCategory.value = cat;
      performSearch();
    }
  }

  Future<void> performSearch() async {
    try {
      isLoading.value = true;
      final results = await _webImageService.searchWebImages(
        query: searchController.text,
        category: selectedCategory.value,
      );
      searchResults.assignAll(results);
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    performSearch();
  }

  Future<void> traceWebImage(WebImageModel webImage) async {
    try {
      AppHelpers.hapticLight();
      isDownloading.value = true;
      downloadingTitle.value = webImage.title;

      AppHelpers.showInfoSnackbar(
        'Downloading Artwork',
        'Preparing "${webImage.title}" for AR tracing...',
      );

      final File localFile = await _webImageService.downloadAndCacheImage(webImage.imageUrl);

      final drawing = DrawingModel(
        id: 'web_${DateTime.now().millisecondsSinceEpoch}',
        title: webImage.title,
        categoryId: webImage.category.toLowerCase(),
        categoryName: webImage.category,
        assetPath: localFile.path,
        isLocalFile: true,
        difficulty: DrawingDifficulty.intermediate,
        description: 'Imported from Web (${webImage.source}) for AR Tracing.',
      );

      _storageService.addRecentDrawing(drawing.id);

      isDownloading.value = false;
      Get.toNamed(Routes.tracing, arguments: drawing);
    } catch (e) {
      isDownloading.value = false;
      AppHelpers.showErrorSnackbar(
        'Download Failed',
        'Could not load the image from the web. Please check your connection or try another image.',
      );
    }
  }

  Future<void> traceFromUrl() async {
    final rawUrl = urlController.text.trim();
    if (!_webImageService.isValidImageUrl(rawUrl)) {
      AppHelpers.showErrorSnackbar(
        'Invalid Link',
        'Please enter a valid HTTP or HTTPS image URL (e.g. ending with .png, .jpg, or .webp).',
      );
      return;
    }

    try {
      AppHelpers.hapticLight();
      isDownloading.value = true;
      downloadingTitle.value = 'Web Link Photo';

      AppHelpers.showInfoSnackbar(
        'Fetching Image',
        'Downloading image from provided web URL...',
      );

      final File localFile = await _webImageService.downloadAndCacheImage(rawUrl);

      final drawing = DrawingModel(
        id: 'url_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Online Web Image',
        categoryId: 'web_link',
        categoryName: 'Web Link',
        assetPath: localFile.path,
        isLocalFile: true,
        difficulty: DrawingDifficulty.intermediate,
        description: 'Custom image traced directly from Web link: $rawUrl',
      );

      _storageService.addRecentDrawing(drawing.id);

      isDownloading.value = false;
      urlController.clear();
      Get.toNamed(Routes.tracing, arguments: drawing);
    } catch (e) {
      isDownloading.value = false;
      AppHelpers.showErrorSnackbar(
        'Failed to Load Link',
        'Could not download image from the provided link. Ensure the link points directly to an image file.',
      );
    }
  }
}

