import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/categories.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../providers/wardrobe_provider.dart';
import 'widgets/wardrobe_grid_item.dart';

/// Wardrobe screen — Instagram-inspired
class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(wardrobeCategoryFilterProvider);
    final itemsAsync = ref.watch(wardrobeItemsProvider);
    final countAsync = ref.watch(wardrobeCountProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header — Instagram style (white bg, extends behind status bar)
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // R logo + two dots + title
                  Row(
                    children: [
                      const Text(
                        'R',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      const SizedBox(width: 3),
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 4.5,
                              height: 4.5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2.5),
                            Container(
                              width: 4.5,
                              height: 4.5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '내 옷장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTitle,
                        ),
                      ),
                    ],
                  ),
                  // Item count
                  countAsync.when(
                    data: (count) => Text(
                      isPremium ? '$count' : '$count/${AppConfig.freeWardrobeLimit}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textCaption,
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // Story-like category row with counts
            Container(
              color: Colors.white,
              child: SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  children: [
                    _CategoryCircle(
                      label: '전체',
                      count: countAsync.valueOrNull ?? 0,
                      isSelected: selectedCategory == null,
                      onTap: () => ref
                          .read(wardrobeCategoryFilterProvider.notifier)
                          .state = null,
                    ),
                    ...ItemCategory.values.map((category) {
                      return _CategoryCircle(
                        label: category.korean,
                        count: 0, // Will show from filtered data
                        isSelected: selectedCategory == category,
                        onTap: () => ref
                            .read(wardrobeCategoryFilterProvider.notifier)
                            .state = category,
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Masonry grid
            Expanded(
              child: itemsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(wardrobeItemsProvider);
                      ref.invalidate(wardrobeCountProvider);
                    },
                    child: MasonryGridView.count(
                      padding: const EdgeInsets.all(3),
                      crossAxisCount: 2,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return WardrobeGridItem(
                          item: item,
                          height: index % 3 == 0 ? 180.0 : (index % 3 == 1 ? 140.0 : 165.0),
                          onTap: () => context.push(
                            '/wardrobe/${item.id}',
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => _buildLoadingGrid(),
                error: (error, _) => _buildErrorState(context, ref, error),
              ),
            ),
          ],
      ),
      // FAB — 48x48, borderRadius 14
      floatingActionButton: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.wardrobeAdd),
          backgroundColor: AppColors.primary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checkroom,
            size: 48,
            color: AppColors.textCaption.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '아직 등록된 옷이 없어요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '오늘 입은 옷을 찍어서 시작해보세요',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textCaption,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.wardrobeAdd),
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text('아이템 추가'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(3),
      crossAxisCount: 2,
      mainAxisSpacing: 3,
      crossAxisSpacing: 3,
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        height: index % 3 == 0 ? 180 : (index % 3 == 1 ? 140 : 165),
        color: AppColors.chipInactive,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          const Text(
            '데이터를 불러올 수 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              ref.invalidate(wardrobeItemsProvider);
              ref.invalidate(wardrobeCountProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

/// Story-style category circle with count number
class _CategoryCircle extends StatelessWidget {
  const _CategoryCircle({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Outer ring
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: 2,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.primaryLight
                      : AppColors.background,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textCaption,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.textTitle
                    : AppColors.textCaption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
