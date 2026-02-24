import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/utils/color_utils.dart';
import '../../data/models/wardrobe_item.dart';

/// Masonry grid tile — no border radius, gradient overlay with category + name
class WardrobeGridItem extends StatelessWidget {
  const WardrobeGridItem({
    super.key,
    required this.item,
    required this.onTap,
    this.height = 180,
  });

  final WardrobeItem item;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background color fallback
            Container(color: ColorUtils.hexToColor(item.colorHex)),

            // Image
            CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: ColorUtils.hexToColor(item.colorHex),
              ),
              errorWidget: (context, url, error) => Container(
                color: ColorUtils.hexToColor(item.colorHex),
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                ),
              ),
            ),

            // Bottom gradient overlay with category + name
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _categoryLabel(item.category),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.subcategory ?? _categoryLabel(item.category),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
