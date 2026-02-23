import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/categories.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../providers/wardrobe_provider.dart';
import 'widgets/wardrobe_grid_item.dart';

/// S06: Wardrobe Grid
class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(wardrobeCategoryFilterProvider);
    final itemsAsync = ref.watch(wardrobeItemsProvider);
    final countAsync = ref.watch(wardrobeCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('옷장'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.wardrobeAdd),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      '전체',
                      style: TextStyle(
                        color: selectedCategory == null
                            ? Colors.white
                            : AppColors.textBody,
                      ),
                    ),
                    selected: selectedCategory == null,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.chipInactive,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: selectedCategory == null
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                    onSelected: (_) => ref
                        .read(wardrobeCategoryFilterProvider.notifier)
                        .state = null,
                  ),
                ),
                ...ItemCategory.values.map((category) {
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        category.korean,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textBody,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.chipInactive,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                      onSelected: (_) => ref
                          .read(wardrobeCategoryFilterProvider.notifier)
                          .state = category,
                    ),
                  );
                }),
              ],
            ),
          ),

          // Free tier progress bar (hidden for premium users)
          if (!ref.watch(isPremiumProvider))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: countAsync.when(
                data: (count) => _buildProgressBar(count),
                loading: () => _buildProgressBar(0),
                error: (_, _) => _buildProgressBar(0),
              ),
            ),

          // Item grid
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
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return WardrobeGridItem(
                        item: item,
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
    );
  }

  Widget _buildProgressBar(int count) {
    final limit = AppConfig.freeWardrobeLimit;
    final ratio = count / limit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '무료 한도',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textCaption,
              ),
            ),
            Text(
              '$count / $limit벌',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textCaption,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: ratio.clamp(0.0, 1.0),
          backgroundColor: AppColors.divider,
          valueColor: AlwaysStoppedAnimation<Color>(
            ratio >= 1.0 ? AppColors.error : AppColors.primary,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checkroom,
            size: 64,
            color: AppColors.textCaption.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 등록된 옷이 없어요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
            ),
          ),
          const SizedBox(height: 8),
          Text(
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
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: 9,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: AppColors.chipInactive,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
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
