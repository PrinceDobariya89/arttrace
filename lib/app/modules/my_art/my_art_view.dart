import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/utils/helpers.dart';
import '../../common/widgets/banner_ad_widget.dart';
import '../../common/widgets/drawing_card.dart';
import '../../common/widgets/empty_state.dart';
import '../../data/models/artwork_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import 'my_art_controller.dart';

class MyArtView extends GetView<MyArtController> {
  const MyArtView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Art & Traces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.travel_explore_rounded),
            tooltip: 'Explore from Browser',
            onPressed: () => Get.toNamed(Routes.webExplorer),
          ),
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_rounded),
            tooltip: 'Trace from Gallery',
            onPressed: controller.importAndTraceCustomImage,
          ),
        ],
        bottom: TabBar(
          controller: controller.tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          tabs: const [
            Tab(text: 'Saved Traces'),
            Tab(text: 'Favorites'),
            Tab(text: 'Recent'),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          // 1. Saved Traces Tab
          _buildSavedTracesTab(context),

          // 2. Favorites Tab
          _buildFavoritesTab(context),

          // 3. Recent Drawings Tab
          _buildRecentTab(context),
        ],
      ),
    );
  }

  Widget _buildSavedTracesTab(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.savedArtworks.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.draw_rounded,
                title: 'No Traced Drawings Yet',
                message: 'Start an AR tracing session and tap "Capture & Save" to store your drawings here!',
                buttonText: 'Trace a Custom Photo',
                onButtonPressed: controller.importAndTraceCustomImage,
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.76,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: controller.savedArtworks.length,
              itemBuilder: (context, index) {
                final artwork = controller.savedArtworks[index];
                return _buildSavedArtworkCard(context, artwork);
              },
            );
          }),
        ),
        const BannerAdWidget(),
      ],
    );
  }

  Widget _buildSavedArtworkCard(BuildContext context, ArtworkModel artwork) {
    final file = File(artwork.filePath);
    final exists = file.existsSync();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                exists
                    ? Image.file(file, fit: BoxFit.cover)
                    : Container(
                        color: Colors.black12,
                        child: const Icon(Icons.broken_image_rounded, size: 40),
                      ),
                // Top Overlay Share & Delete buttons
                Positioned(
                  top: 6,
                  right: 6,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSmallIconButton(
                        context,
                        Icons.share_rounded,
                        () => controller.shareArtwork(artwork),
                      ),
                      const SizedBox(width: 4),
                      _buildSmallIconButton(
                        context,
                        Icons.delete_outline_rounded,
                        () => controller.deleteArtwork(artwork),
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artwork.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  AppHelpers.formatDate(artwork.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIconButton(BuildContext context, IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: color ?? Colors.white),
      ),
    );
  }

  Widget _buildFavoritesTab(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.favoriteDrawings.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.favorite_border_rounded,
                title: 'No Favorites Yet',
                message: 'Tap the heart icon on any artwork to save it to your favorites list.',
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: controller.favoriteDrawings.length,
              itemBuilder: (context, index) {
                final drawing = controller.favoriteDrawings[index];
                return DrawingCard(
                  drawing: drawing,
                  onTap: () => controller.openDrawingDetail(drawing),
                );
              },
            );
          }),
        ),
        const BannerAdWidget(),
      ],
    );
  }

  Widget _buildRecentTab(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.recentDrawings.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.history_rounded,
                title: 'No Recent Drawings',
                message: 'Drawings you view or trace will appear here for quick access.',
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: controller.recentDrawings.length,
              itemBuilder: (context, index) {
                final drawing = controller.recentDrawings[index];
                return DrawingCard(
                  drawing: drawing,
                  onTap: () => controller.openDrawingDetail(drawing),
                );
              },
            );
          }),
        ),
        const BannerAdWidget(),
      ],
    );
  }
}

