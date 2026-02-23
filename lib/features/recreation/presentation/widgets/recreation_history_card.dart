import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/look_recreation.dart';

class RecreationHistoryCard extends StatelessWidget {
  const RecreationHistoryCard({
    super.key,
    required this.recreation,
    this.onTap,
  });

  final LookRecreation recreation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: recreation.referenceImageUrl,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  width: 140,
                  height: 140,
                  color: AppColors.chipInactive,
                ),
                errorWidget: (_, _, _) => Container(
                  width: 140,
                  height: 140,
                  color: AppColors.chipInactive,
                  child: const Icon(Icons.image, size: 32),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  _scoreBadge(recreation.overallScore),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _timeAgo(recreation.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textCaption,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreBadge(int score) {
    final color = score >= 70
        ? AppColors.success
        : score >= 50
            ? AppColors.warning
            : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$score%',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dateTime.month}/${dateTime.day}';
  }
}
