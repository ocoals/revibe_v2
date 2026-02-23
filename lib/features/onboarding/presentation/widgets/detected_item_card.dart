import 'package:flutter/material.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/detected_item.dart';

class DetectedItemCard extends StatelessWidget {
  const DetectedItemCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onCategoryChanged,
  });

  final DetectedItem item;
  final VoidCallback onToggle;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final categoryLabel = _getCategoryKorean(item.category);
    final color = _parseHex(item.colorHex);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: item.isSelected ? AppColors.primary : AppColors.divider,
          width: item.isSelected ? 1.5 : 1,
        ),
      ),
      color: item.isSelected ? AppColors.primaryLight : AppColors.cardBackground,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: checkbox + color swatch + name
              Row(
                children: [
                  Icon(
                    item.isSelected
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: item.isSelected
                        ? AppColors.primary
                        : AppColors.textCaption,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  // Color swatch
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.divider,
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryLabel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTitle,
                          ),
                        ),
                        if (item.subcategory != null &&
                            item.subcategory!.isNotEmpty)
                          Text(
                            item.subcategory!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textBody,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Color name badge
                  if (item.colorName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.chipInactive,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.colorName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textBody,
                        ),
                      ),
                    ),
                ],
              ),

              // Category change chips (only when selected)
              if (item.isSelected) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: ItemCategory.values.map((cat) {
                    final isActive = item.category == cat.dbValue;
                    return SizedBox(
                      height: 28,
                      child: FilterChip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        label: Text(
                          cat.korean,
                          style: TextStyle(
                            fontSize: 11,
                            color: isActive
                                ? Colors.white
                                : AppColors.chipInactiveText,
                          ),
                        ),
                        selected: isActive,
                        selectedColor: AppColors.chipActive,
                        backgroundColor: AppColors.chipInactive,
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color:
                              isActive ? AppColors.primary : AppColors.divider,
                        ),
                        onSelected: (_) => onCategoryChanged(cat.dbValue),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryKorean(String dbValue) {
    try {
      return ItemCategory.fromDb(dbValue).korean;
    } catch (_) {
      return dbValue;
    }
  }

  Color _parseHex(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }
}
