import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../providers/recreation_process_provider.dart';

/// S10: Look recreation - analyzing (loading state)
class AnalyzingScreen extends ConsumerStatefulWidget {
  const AnalyzingScreen({super.key});

  @override
  ConsumerState<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends ConsumerState<AnalyzingScreen> {
  int _fakeStep = 0; // 0: detecting, 1: analyzing, 2: matching
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Timer-based fake step progression for UX
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_fakeStep < 2) {
        setState(() => _fakeStep++);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final processState = ref.watch(recreationProcessProvider);

    // Navigate on completion
    ref.listen(recreationProcessProvider, (prev, next) {
      if (next.step == RecreationStep.completed && next.result != null) {
        context.pushReplacement('/recreation/result/${next.result!.id}');
      } else if (next.step == RecreationStep.error) {
        _showErrorDialog(next.errorCode, next.errorMessage);
      }
    });

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
                _AnalysisStep(
                  label: '아이템 감지 완료',
                  isDone: _fakeStep >= 1 ||
                      processState.step.index >= RecreationStep.analyzing.index,
                ),
                const SizedBox(height: 12),
                _AnalysisStep(
                  label: '색상/스타일 분석 완료',
                  isDone: _fakeStep >= 2 ||
                      processState.step.index >= RecreationStep.matching.index,
                ),
                const SizedBox(height: 12),
                _AnalysisStep(
                  label: '내 옷장에서 매칭 중...',
                  isDone: processState.step == RecreationStep.completed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String? errorCode, String? errorMessage) {
    final messages = _getErrorMessages(errorCode);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(messages.$1),
        content: Text(messages.$2),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop(); // Back to input
            },
            child: const Text('취소'),
          ),
          if (errorCode != 'NO_FASHION_ITEMS' &&
              errorCode != 'RECREATION_LIMIT_REACHED')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final bytes =
                    ref.read(recreationProcessProvider).imageBytes;
                if (bytes != null) {
                  ref
                      .read(recreationProcessProvider.notifier)
                      .startAnalysis(bytes);
                }
              },
              child: const Text('다시 시도'),
            ),
          if (errorCode == 'NO_FASHION_ITEMS')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop(); // Back to input to pick another image
              },
              child: const Text('다른 이미지 선택'),
            ),
        ],
      ),
    );
  }

  (String, String) _getErrorMessages(String? code) {
    return switch (code) {
      'RECREATION_LIMIT_REACHED' => (
        '한도 초과',
        '이번 달 무료 룩 재현을 모두 사용했어요',
      ),
      'INVALID_IMAGE' => ('이미지 오류', '이미지를 처리할 수 없어요'),
      'NO_FASHION_ITEMS' => (
        '패션 아이템 없음',
        '패션 아이템을 찾을 수 없어요.\n사람이 옷을 입은 사진을 선택해주세요',
      ),
      'AI_TIMEOUT' => ('시간 초과', '분석 시간이 초과됐어요'),
      'AI_ERROR' => ('분석 오류', '일시적인 오류가 발생했어요'),
      _ => ('오류', '알 수 없는 오류가 발생했어요'),
    };
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
