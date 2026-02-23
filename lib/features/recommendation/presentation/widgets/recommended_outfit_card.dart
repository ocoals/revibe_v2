import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../daily/providers/daily_provider.dart';
import '../../../wardrobe/data/models/wardrobe_item.dart';
import '../../providers/recommendation_provider.dart';
import '../../data/models/recommendation_result.dart';

class RecommendedOutfitCard extends ConsumerWidget {
  const RecommendedOutfitCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recAsync = ref.watch(todayRecommendationProvider);

    return recAsync.when(
      loading: () => _buildShimmer(),
      error: (_, _) => const SizedBox.shrink(),
      data: (result) {
        if (result == null) return _buildEmptyState(context);

        final outfit = ref.watch(currentRecommendedOutfitProvider);
        if (outfit == null) return const SizedBox.shrink();

        final weatherCtx = result.weather;
        final totalCount = 1 + result.alternatives.length;
        final currentIndex = ref.watch(recommendationIndexProvider);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(weatherCtx),
              const SizedBox(height: 16),
              _buildItemRow(outfit),
              const SizedBox(height: 12),
              if (outfit.reasons.isNotEmpty) ...[
                _buildReasons(outfit.reasons),
                const SizedBox(height: 12),
              ],
              _buildActions(context, ref, outfit, currentIndex, totalCount),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(WeatherContext? weather) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '오늘의 추천 코디',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textTitle,
          ),
        ),
        if (weather != null)
          Row(
            children: [
              Image.network(
                'https://openweathermap.org/img/wn/${weather.iconCode}@2x.png',
                width: 28,
                height: 28,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
              Text(
                '${weather.temperature.round()}°C ${weather.cityName}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textCaption,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildItemRow(RecommendedOutfit outfit) {
    final items = [
      outfit.top,
      outfit.bottom,
      if (outfit.outerwear != null) outfit.outerwear!,
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _ItemThumbnail(item: item),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReasons(List<RecommendationReason> reasons) {
    final displayed = reasons.take(2).toList();
    return Wrap(
      spacing: 8,
      children: displayed.map((r) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.tagBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            r.reason,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.tagText,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    RecommendedOutfit outfit,
    int currentIndex,
    int totalCount,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _saveAsDaily(context, ref, outfit),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('이 코디로 기록'),
          ),
        ),
        if (totalCount > 1) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              final next = (currentIndex + 1) % totalCount;
              ref.read(recommendationIndexProvider.notifier).state = next;
            },
            child: const Text(
              '다른 추천 ›',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _saveAsDaily(
    BuildContext context,
    WidgetRef ref,
    RecommendedOutfit outfit,
  ) async {
    final repo = ref.read(dailyRepositoryProvider);
    final itemIds = [
      outfit.top.id,
      outfit.bottom.id,
      if (outfit.outerwear != null) outfit.outerwear!.id,
    ];

    try {
      await repo.saveOutfit(
        date: DateTime.now(),
        itemIds: itemIds,
        notes: '추천 코디로 기록',
      );

      final now = DateTime.now();
      final monthKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';
      ref.invalidate(monthlyOutfitsProvider(monthKey));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('오늘 코디가 기록되었어요!')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기록에 실패했어요. 다시 시도해주세요.')),
        );
      }
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.checkroom, color: AppColors.primary, size: 32),
          const SizedBox(height: 8),
          const Text(
            '옷장에 아이템을 추가하면\n코디를 추천해드려요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.push(AppRoutes.wardrobeAdd),
            child: const Text('아이템 추가하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.chipInactive,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _ItemThumbnail extends StatelessWidget {
  const _ItemThumbnail({required this.item});

  final WardrobeItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                color: AppColors.chipInactive,
              ),
              errorWidget: (_, _, _) => Container(
                color: AppColors.chipInactive,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.subcategory ?? item.category,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textCaption,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
