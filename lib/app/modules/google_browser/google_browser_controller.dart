import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../common/utils/helpers.dart';
import '../../data/models/drawing_model.dart';
import '../../routes/app_routes.dart';
import '../../services/storage/storage_service.dart';
import '../../services/web_image/web_image_service.dart';

class GoogleBrowserController extends GetxController {
  final WebImageService _webImageService = WebImageService();
  final StorageService _storageService = Get.find<StorageService>();

  late final WebViewController webViewController;
  late final String initialKeyword;
  late final String searchUrl;

  final RxBool isLoadingPage = true.obs;
  final RxDouble pageProgress = 0.0.obs;
  final RxnString selectedImageUrl = RxnString();
  final RxString selectedImageTitle = ''.obs;
  final RxBool isProcessing = false.obs;

  static const String _jsInjection = '''
    (function() {
      function notifyFlutter(img) {
        if (!img) return;
        var src = img.currentSrc || img.src || img.getAttribute('data-src') || img.getAttribute('src');
        if (!src) return;
        if (src.indexOf('http') === 0 || src.indexOf('data:image') === 0) {
          try {
            var all = document.querySelectorAll('.arttrace-glow');
            for (var i = 0; i < all.length; i++) {
              all[i].classList.remove('arttrace-glow');
              all[i].style.outline = '';
            }
            img.classList.add('arttrace-glow');
            img.style.outline = '4px solid #6C5CE7';
            img.style.outlineOffset = '2px';
            img.scrollIntoView({ behavior: 'smooth', block: 'center' });
          } catch(e) {}

          var alt = img.getAttribute('alt') || '';
          if (window.ImageSelectedChannel) {
            window.ImageSelectedChannel.postMessage(JSON.stringify({
              url: src,
              title: alt
            }));
          }
        }
      }

      document.addEventListener('click', function(e) {
        var el = e.target;
        var img = null;
        if (el.tagName && el.tagName.toLowerCase() === 'img') {
          img = el;
        } else {
          img = el.closest('img') || el.querySelector('img');
        }
        if (img) {
          notifyFlutter(img);
        }
      }, true);
    })();
  ''';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String && args.trim().isNotEmpty) {
      initialKeyword = args.trim();
    } else {
      initialKeyword = 'easy sketches';
    }

    // Format query as requested: "Colorful photo of {keyword} for drawing"
    final formattedQuery = 'Colorful photo of $initialKeyword for drawing (only image)';
    searchUrl = 'https://www.google.com/search?tbm=isch&q=${Uri.encodeComponent(formattedQuery)}';

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            pageProgress.value = progress / 100.0;
          },
          onPageStarted: (String url) {
            isLoadingPage.value = true;
          },
          onPageFinished: (String url) {
            isLoadingPage.value = false;
            webViewController.runJavaScript(_jsInjection);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web error: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'ImageSelectedChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleImageTap(message.message);
        },
      )
      ..loadRequest(Uri.parse(searchUrl));
  }

  void _handleImageTap(String rawJson) {
    try {
      final Map<String, dynamic> data = jsonDecode(rawJson);
      final url = data['url'] as String?;
      final title = data['title'] as String? ?? '';
      if (url != null && url.isNotEmpty) {
        AppHelpers.hapticLight();
        selectedImageUrl.value = url;
        selectedImageTitle.value = title.isNotEmpty ? title : '$initialKeyword Drawing';
      }
    } catch (e) {
      debugPrint('Error parsing tapped image data: $e');
    }
  }

  void clearSelection() {
    selectedImageUrl.value = null;
    selectedImageTitle.value = '';
  }

  Future<void> traceSelectedImage() async {
    final imgUrl = selectedImageUrl.value;
    if (imgUrl == null || imgUrl.isEmpty) {
      AppHelpers.showInfoSnackbar(
        'Tap an Image First',
        'Please tap any image in Google Images to select it for drawing.',
      );
      return;
    }

    try {
      AppHelpers.hapticMedium();
      isProcessing.value = true;

      AppHelpers.showInfoSnackbar(
        'Importing Image',
        'Downloading and preparing image for AR Tracing...',
      );

      final File localFile = await _webImageService.downloadOrSaveImage(imgUrl);

      final drawing = DrawingModel(
        id: 'google_${DateTime.now().millisecondsSinceEpoch}',
        title: selectedImageTitle.value.isNotEmpty
            ? selectedImageTitle.value
            : '$initialKeyword Sketch',
        categoryId: 'google_web',
        categoryName: 'Google Images',
        assetPath: localFile.path,
        isLocalFile: true,
        difficulty: DrawingDifficulty.intermediate,
        description: 'Captured from Google Web Search: "$initialKeyword"',
      );

      _storageService.addRecentDrawing(drawing.id);

      isProcessing.value = false;
      // Navigate to AR Tracing
      Get.toNamed(Routes.tracing, arguments: drawing);
    } catch (e) {
      isProcessing.value = false;
      AppHelpers.showErrorSnackbar(
        'Import Failed',
        'Could not download this image. Please tap another image or try again.',
      );
    }
  }

  void refreshPage() {
    webViewController.reload();
  }
}

