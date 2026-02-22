import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// S12: Gap analysis bottom sheet
class GapAnalysisSheet extends StatelessWidget {
  const GapAnalysisSheet({super.key, required this.recreationId});

  final String recreationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('갭 분석')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '이 아이템이 있으면 완벽해요!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 24),

              // Gap item placeholder
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gapCardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gapCardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '없는 아이템',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTitle,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ShoppingLink(label: '무신사에서 찾기', onTap: () {}),
                    const SizedBox(height: 8),
                    _ShoppingLink(label: '에이블리에서 찾기', onTap: () {}),
                    const SizedBox(height: 8),
                    _ShoppingLink(label: '지그재그에서 찾기', onTap: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShoppingLink extends StatelessWidget {
  const _ShoppingLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
