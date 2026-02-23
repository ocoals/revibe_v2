import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/color_utils.dart';
import '../../data/models/wardrobe_item.dart';

/// Grid tile for wardrobe items with image, category badge, and color dot
class WardrobeGridItem extends StatelessWidget {
  const WardrobeGridItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  final WardrobeItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image with shimmer loading
            CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.chipInactive,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.chipInactive,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textCaption,
                ),
              ),
            ),

            // Category badge (top-left)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _categoryLabel(item.category),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Color dot (bottom-right)
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: ColorUtils.hexToColor(item.colorHex),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(String category) {
    try {
      return ItemCategory.fromDb(category).korean;
    } catch (_) {
      return category;
    }
  }

}
