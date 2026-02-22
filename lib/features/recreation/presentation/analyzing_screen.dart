import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// S10: Look recreation - analyzing (loading state)
class AnalyzingScreen extends StatelessWidget {
  const AnalyzingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  '분석 중이에요',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTitle,
                  ),
                ),
                const SizedBox(height: 32),
                _AnalysisStep(label: '아이템 감지', isDone: false),
                const SizedBox(height: 12),
                _AnalysisStep(label: '색상/스타일 분석', isDone: false),
                const SizedBox(height: 12),
                _AnalysisStep(label: '내 옷장에서 매칭 중...', isDone: false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalysisStep extends StatelessWidget {
  const _AnalysisStep({required this.label, required this.isDone});

  final String label;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isDone ? AppColors.success : AppColors.textCaption,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDone ? AppColors.textTitle : AppColors.textCaption,
            fontWeight: isDone ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
