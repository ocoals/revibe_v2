import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../data/models/gap_item.dart';

/// S12: Gap analysis bottom sheet
class GapAnalysisSheet extends StatelessWidget {
  const GapAnalysisSheet({super.key, required this.gapItem});

  final GapItem gapItem;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '이 아이템이 있으면 완벽해요!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textTitle,
              ),
            ),
            const SizedBox(height: 16),

            // Gap item description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gapCardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gapCardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.gapCardBorder.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      gapItem.description,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTitle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Shopping links
            if (gapItem.deeplinks.containsKey('musinsa'))
              _ShoppingLink(
                label: '무신사에서 찾기',
                url: gapItem.deeplinks['musinsa']!,
              ),
            const SizedBox(height: 8),
            if (gapItem.deeplinks.containsKey('ably'))
              _ShoppingLink(
                label: '에이블리에서 찾기',
                url: gapItem.deeplinks['ably']!,
              ),
            const SizedBox(height: 8),
            if (gapItem.deeplinks.containsKey('zigzag'))
              _ShoppingLink(
                label: '지그재그에서 찾기',
                url: gapItem.deeplinks['zigzag']!,
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ShoppingLink extends StatelessWidget {
  const _ShoppingLink({required this.label, required this.url});

  final String label;
  final String url;

  Future<void> _launch() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _launch,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.open_in_new,
              size: 16,
              color: AppColors.textCaption,
            ),
          ],
        ),
      ),
    );
  }
}
