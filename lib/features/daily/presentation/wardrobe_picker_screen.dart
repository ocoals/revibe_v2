import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/categories.dart';
import '../../../core/constants/colors.dart';
import '../../wardrobe/data/models/wardrobe_item.dart';
import '../../wardrobe/providers/wardrobe_provider.dart';
import '../providers/daily_record_form_provider.dart';

/// Wardrobe item picker with multi-select and category filter
class WardrobePickerScreen extends ConsumerStatefulWidget {
  const WardrobePickerScreen({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<WardrobePickerScreen> createState() =>
      _WardrobePickerScreenState();
}

class _WardrobePickerScreenState extends ConsumerState<WardrobePickerScreen> {
  ItemCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(dailyRecordFormProvider(widget.date));
    final itemsAsync = ref.watch(wardrobeItemsProvider);
    final selectedIds = formState.selectedItems.map((i) => i.id).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('아이템 선택'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '완료 (${selectedIds.length})',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _CategoryChip(
                  label: '전체',
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                ...ItemCategory.values.map((cat) => _CategoryChip(
                      label: cat.korean,
                      isSelected: _selectedCategory == cat,
                      onTap: () => setState(() => _selectedCategory = cat),
                    )),
              ],
            ),
          ),
          const Divider(height: 1),

          // Items grid
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                final filtered = _selectedCategory == null
                    ? items
                    : items
                        .where(
                            (i) => i.category == _selectedCategory!.dbValue)
                        .toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      '해당 카테고리에 아이템이 없어요',
                      style: TextStyle(color: AppColors.textCaption),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isSelected = selectedIds.contains(item.id);
                    return _ItemGridTile(
                      item: item,
                      isSelected: isSelected,
                      onTap: () {
                        ref
                            .read(dailyRecordFormProvider(widget.date).notifier)
                            .toggleItem(item);
                      },
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  '아이템을 불러올 수 없어요',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.chipActive : AppColors.chipInactive,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.chipInactiveText,
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemGridTile extends StatelessWidget {
  const _ItemGridTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final WardrobeItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: AppColors.chipInactive,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.chipInactive,
                  child: const Icon(Icons.broken_image,
                      color: AppColors.textCaption),
                ),
              ),
              // Bottom label
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Text(
                    item.subcategory ?? item.category,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // Selected check overlay
              if (isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
