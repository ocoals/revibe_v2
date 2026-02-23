import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/categories.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';
import '../data/models/wardrobe_item.dart';
import '../providers/wardrobe_provider.dart';

/// S07: Wardrobe item detail
class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  static const _seasonLabels = {
    'spring': '봄',
    'summer': '여름',
    'fall': '가을',
    'winter': '겨울',
  };

  static const _fitLabels = {
    'oversized': '오버사이즈',
    'regular': '레귤러',
    'slim': '슬림',
  };

  static const _patternLabels = {
    'solid': '솔리드',
    'stripe': '스트라이프',
    'check': '체크',
    'floral': '플로럴',
    'dot': '도트',
    'print': '프린트',
    'other': '기타',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(wardrobeItemProvider(itemId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('아이템 상세'),
        actions: [
          IconButton(
            onPressed: () => _showDeleteDialog(context, ref),
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
      body: itemAsync.when(
        data: (item) => _buildDetail(context, ref, item),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                '아이템을 불러올 수 없습니다',
                style: TextStyle(color: AppColors.textBody),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.invalidate(wardrobeItemProvider(itemId)),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, WidgetRef ref, WardrobeItem item) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large image
          CachedNetworkImage(
            imageUrl: item.imageUrl,
            width: screenWidth,
            height: screenWidth,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: screenWidth,
              height: screenWidth,
              color: AppColors.chipInactive,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              width: screenWidth,
              height: screenWidth,
              color: AppColors.chipInactive,
              child: const Icon(
                Icons.broken_image_outlined,
                size: 64,
                color: AppColors.textCaption,
              ),
            ),
          ),

          // Metadata section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                _metadataRow(
                  '카테고리',
                  _categoryLabel(item.category, item.subcategory),
                ),
                const Divider(height: 24),

                // Color
                _colorRow(item.colorHex, item.colorName),
                const Divider(height: 24),

                // Fit
                if (item.fit != null) ...[
                  _metadataRow('핏', _fitLabels[item.fit] ?? item.fit!),
                  const Divider(height: 24),
                ],

                // Pattern
                if (item.pattern != null) ...[
                  _metadataRow(
                    '패턴',
                    _patternLabels[item.pattern] ?? item.pattern!,
                  ),
                  const Divider(height: 24),
                ],

                // Brand
                if (item.brand != null && item.brand!.isNotEmpty) ...[
                  _metadataRow('브랜드', item.brand!),
                  const Divider(height: 24),
                ],

                // Season
                _metadataRow(
                  '계절',
                  item.season
                      .map((s) => _seasonLabels[s] ?? s)
                      .join(', '),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metadataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textCaption,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textTitle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _colorRow(String colorHex, String colorName) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '색상',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textCaption,
            ),
          ),
        ),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _hexToColor(colorHex),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.divider),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          colorName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textTitle,
          ),
        ),
      ],
    );
  }

  String _categoryLabel(String category, String? subcategory) {
    try {
      final cat = ItemCategory.fromDb(category);
      final label = cat.korean;
      if (subcategory != null) {
        final subs = subcategories[cat];
        final sub = subs?.where((s) => s.dbValue == subcategory).firstOrNull;
        if (sub != null) return '$label > ${sub.korean}';
      }
      return label;
    } catch (_) {
      return category;
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('아이템 삭제'),
        content: const Text('이 아이템을 옷장에서 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repo = ref.read(wardrobeRepositoryProvider);
        await repo.deleteItem(itemId);
        ref.invalidate(wardrobeItemsProvider);
        ref.invalidate(wardrobeCountProvider);
        if (context.mounted) {
          context.go(AppRoutes.wardrobe);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('삭제에 실패했습니다: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  static Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
