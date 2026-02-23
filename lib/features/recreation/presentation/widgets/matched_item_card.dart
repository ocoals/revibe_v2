import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/matched_item.dart';

class MatchedItemCard extends StatelessWidget {
  const MatchedItemCard({
    super.key,
    required this.matchedItem,
    required this.refDescription,
    this.onTap,
  });

  final MatchedItem matchedItem;
  final String refDescription;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final item = matchedItem.wardrobeItem;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(color: AppColors.success, width: 3),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.chipInactive,
                ),
                errorWidget: (_, _, _) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.chipInactive,
                  child: const Icon(Icons.image, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$refDescription  →  ${item.colorName} ${item.subcategory ?? item.category} ${matchedItem.score}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTitle,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (matchedItem.matchReasons.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      matchedItem.matchReasons.join(', '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textCaption,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textCaption, size: 20),
          ],
        ),
      ),
    );
  }
}
