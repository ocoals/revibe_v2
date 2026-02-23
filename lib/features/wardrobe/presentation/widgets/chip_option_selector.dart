import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

/// Single-select chip option (used for Fit, Pattern)
class ChipOptionSelector extends StatelessWidget {
  const ChipOptionSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  /// Map of dbValue -> display label
  final Map<String, String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries.map((entry) {
        final isSelected = selected == entry.key;
        return FilterChip(
          label: Text(
            entry.value,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.chipInactiveText,
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.chipActive,
          backgroundColor: AppColors.chipInactive,
          checkmarkColor: Colors.white,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
          onSelected: (_) => onSelected(entry.key),
        );
      }).toList(),
    );
  }
}

/// Multi-select season selector
class SeasonSelector extends StatelessWidget {
  const SeasonSelector({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final List<String> selected;
  final ValueChanged<String> onToggle;

  static const _seasons = {
    'spring': '봄',
    'summer': '여름',
    'fall': '가을',
    'winter': '겨울',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _seasons.entries.map((entry) {
        final isSelected = selected.contains(entry.key);
        return FilterChip(
          label: Text(
            entry.value,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.chipInactiveText,
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.chipActive,
          backgroundColor: AppColors.chipInactive,
          checkmarkColor: Colors.white,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
          onSelected: (_) => onToggle(entry.key),
        );
      }).toList(),
    );
  }
}
