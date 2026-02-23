import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/gap_item.dart';

class GapItemCard extends StatelessWidget {
  const GapItemCard({
    super.key,
    required this.gapItem,
    this.onFindTap,
  });

  final GapItem gapItem;
  final VoidCallback? onFindTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gapCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.error, width: 3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gapCardBorder.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.help_outline,
              color: AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gapItem.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTitle,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '없는 아이템',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textCaption,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onFindTap,
            child: const Text(
              '찾기 →',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
