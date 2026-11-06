import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../theme/app_colors.dart';
import 'google_browser_controller.dart';

class GoogleImageBrowserView extends GetView<GoogleBrowserController> {
  const GoogleImageBrowserView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Google Images',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            Text(
              'Search: "${controller.initialKeyword}"',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload',
            onPressed: controller.refreshPage,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Loading Progress Indicator
              Obx(() {
                if (!controller.isLoadingPage.value && controller.pageProgress.value >= 1.0) {
                  return const SizedBox.shrink();
                }
                return LinearProgressIndicator(
                  value: controller.pageProgress.value,
                  backgroundColor: Colors.transparent,
                  color: AppColors.primary,
                  minHeight: 3,
                );
              }),

              // 2. Instructions Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.touch_app_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap any image below to select and import it for AR tracing!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. WebView
              Expanded(
                child: WebViewWidget(controller: controller.webViewController),
              ),
            ],
          ),

          // 4. Floating Bottom Action Sheet when an image is selected
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Obx(() {
              final imgUrl = controller.selectedImageUrl.value;
              if (imgUrl == null) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Preview Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: _buildThumbnail(imgUrl),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Label & Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: AppColors.success,
                              ),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Image Selected',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            controller.selectedImageTitle.value.isNotEmpty
                                ? controller.selectedImageTitle.value
                                : 'Ready to trace',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Trace Button
                    ElevatedButton(
                      onPressed: controller.traceSelectedImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.draw_rounded, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Trace',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 2),

                    // Clear selection button
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: controller.clearSelection,
                        tooltip: 'Cancel',
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          // 5. Processing / Downloading Overlay
          Positioned.fill(
            child: Obx(() {
              if (!controller.isProcessing.value) return const SizedBox.shrink();
              return Container(
                color: Colors.black.withValues(alpha: 0.65),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                        SizedBox(height: 18),
                        Text(
                          'Importing Drawing...',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Opening AR camera canvas',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String url) {
    if (url.startsWith('data:image')) {
      try {
        final comma = url.indexOf(',');
        final base64Str = comma != -1 ? url.substring(comma + 1) : url;
        final bytes = base64Decode(base64Str);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return Container(color: Colors.black12, child: const Icon(Icons.image, size: 24));
      }
    } else {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: Colors.black12, child: const Icon(Icons.broken_image, size: 24)),
      );
    }
  }
}

