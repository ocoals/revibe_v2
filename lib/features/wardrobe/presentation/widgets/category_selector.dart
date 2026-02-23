import 'package:flutter/material.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/constants/colors.dart';

/// Main category selector (7 categories as FilterChips)
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ItemCategory.values.map((cat) {
        final isSelected = selected == cat.dbValue;
        return FilterChip(
          label: Text(
            cat.korean,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.chipInactiveText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.chipActive,
          backgroundColor: AppColors.chipInactive,
          checkmarkColor: Colors.white,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
          onSelected: (_) => onSelected(cat.dbValue),
        );
      }).toList(),
    );
  }
}

/// Subcategory selector based on selected main category
class SubcategorySelector extends StatelessWidget {
  const SubcategorySelector({
    super.key,
    required this.category,
    required this.selected,
    required this.onSelected,
  });

  final String category;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final cat = ItemCategory.fromDb(category);
    final subs = subcategories[cat] ?? [];
    if (subs.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: subs.map((sub) {
        final isSelected = selected == sub.dbValue;
        return FilterChip(
          label: Text(
            sub.korean,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.chipInactiveText,
              fontSize: 13,
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.chipActive,
          backgroundColor: AppColors.chipInactive,
          checkmarkColor: Colors.white,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
          onSelected: (_) {
            onSelected(isSelected ? null : sub.dbValue);
          },
        );
      }).toList(),
    );
  }
}
