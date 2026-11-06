import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/banner_ad_widget.dart';
import '../../common/widgets/drawing_card.dart';
import '../../common/widgets/empty_state.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import 'gallery_controller.dart';

class GalleryView extends GetView<GalleryController> {
  const GalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Artwork'),
        actions: [
          IconButton(
            icon: const Icon(Icons.travel_explore_rounded),
            tooltip: 'Explore from Browser',
            onPressed: () => Get.toNamed(
              Routes.webExplorer,
              arguments: controller.searchQuery.value,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Filters',
            onPressed: () {
              controller.clearSearch();
              controller.selectCategory('all');
              controller.selectFilter('all');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search anime, sketch title, tags...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                ),
                suffixIcon: Obx(
                  () => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: controller.clearSearch,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          // Category Chips Horizontal Scroll
          SizedBox(
            height: 44,
            child: Obx(
              () => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = controller.categories[index];
                  final isSelected =
                      controller.selectedCategory.value == cat.id;
                  return ChoiceChip(
                    label: Text(cat.title),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) controller.selectCategory(cat.id);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : (Theme.of(context).brightness == Brightness.dark
                                ? AppColors.borderDark
                                : AppColors.borderLight),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
            ),
          ),

          // Free / Premium / All Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildQuickFilterChip(context, 'all', 'All Access'),
                const SizedBox(width: 8),
                _buildQuickFilterChip(context, 'free', 'Free Only'),
                const SizedBox(width: 8),
                _buildQuickFilterChip(context, 'premium', 'PRO Collection'),
                const Spacer(),
                Obx(
                  () => Text(
                    '${controller.displayedDrawings.length} items',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Drawings Grid
          Expanded(
            child: Obx(() {
              if (controller.displayedDrawings.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.search_off_rounded,
                  title: 'No Local Drawings Found',
                  message:
                      'Try clearing your search term, or explore online sketches and line art from the web browser.',
                  buttonText: controller.searchQuery.value.isNotEmpty
                      ? 'Search Web for "${controller.searchQuery.value}"'
                      : 'Explore from Browser',
                  onButtonPressed: () => Get.toNamed(
                    Routes.webExplorer,
                    arguments: controller.searchQuery.value,
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: controller.displayedDrawings.length,
                itemBuilder: (context, index) {
                  final drawing = controller.displayedDrawings[index];
                  return DrawingCard(
                    drawing: drawing,
                    onTap: () => controller.openDrawingDetail(drawing),
                  );
                },
              );
            }),
          ),

          // Banner Ad at the bottom
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(
    BuildContext context,
    String filterKey,
    String label,
  ) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == filterKey;
      return GestureDetector(
        onTap: () => controller.selectFilter(filterKey),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : null,
            ),
          ),
        ),
      );
    });
  }
}
