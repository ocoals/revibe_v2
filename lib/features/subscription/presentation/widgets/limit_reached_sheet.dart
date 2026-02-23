import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../paywall_screen.dart';

/// Limit type for the bottom sheet.
enum LimitType { wardrobe, recreation }

/// Bottom sheet shown when free tier limit is reached.
class LimitReachedSheet extends StatelessWidget {
  const LimitReachedSheet({
    super.key,
    required this.limitType,
  });

  final LimitType limitType;

  /// Show as a modal bottom sheet.
  static Future<void> show(BuildContext context, LimitType type) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LimitReachedSheet(limitType: type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWardrobe = limitType == LimitType.wardrobe;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.premium.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isWardrobe ? Icons.checkroom : Icons.auto_awesome,
              color: AppColors.premium,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            isWardrobe ? '옷장이 꽉 찼어요!' : '이번 달 무료 횟수를 다 사용했어요',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textTitle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isWardrobe
                ? '프리미엄으로 업그레이드하면\n옷장 한도 없이 등록할 수 있어요'
                : '프리미엄으로 업그레이드하면\n매달 무제한으로 사용할 수 있어요',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textBody,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PaywallScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premium,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                '프리미엄으로 업그레이드',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Secondary action
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              isWardrobe ? '아이템 정리하기' : '다음 달까지 기다리기',
              style: const TextStyle(color: AppColors.textCaption),
            ),
          ),
        ],
      ),
    );
  }
}
