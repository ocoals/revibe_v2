import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';
import '../providers/recreation_process_provider.dart';
import '../providers/usage_provider.dart';
import '../providers/recreation_provider.dart';
import 'widgets/recreation_history_card.dart';

/// S09: Look recreation - reference image input
class ReferenceInputScreen extends ConsumerStatefulWidget {
  const ReferenceInputScreen({super.key});

  @override
  ConsumerState<ReferenceInputScreen> createState() =>
      _ReferenceInputScreenState();
}

class _ReferenceInputScreenState extends ConsumerState<ReferenceInputScreen> {
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );
    if (xFile == null) return;

    final bytes = await xFile.readAsBytes();
    ref.read(recreationProcessProvider.notifier).startAnalysis(bytes);

    if (mounted) {
      context.push(AppRoutes.recreationAnalyzing);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingAsync = ref.watch(remainingRecreationsProvider);
    final historyAsync = ref.watch(recreationHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('룩 재현')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Remaining count
              remainingAsync.when(
                data: (remaining) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '이번 달 잔여 횟수: $remaining/5회',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: remaining > 0
                          ? AppColors.textBody
                          : AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                loading: () => const SizedBox(height: 32),
                error: (_, _) => const SizedBox(height: 32),
              ),
              const SizedBox(height: 16),

              // Image placeholder
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '따라하고 싶은 코디 사진을\n선택해주세요',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pick button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: remainingAsync.when(
                  data: (remaining) => ElevatedButton.icon(
                    onPressed: remaining > 0 ? _pickImage : null,
                    icon: const Icon(Icons.photo_library),
                    label: Text(remaining > 0
                        ? '갤러리에서 선택'
                        : '이번 달 무료 횟수를 모두 사용했어요'),
                  ),
                  loading: () => const ElevatedButton(
                    onPressed: null,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (_, _) => ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('갤러리에서 선택'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '인스타그램 등에서 공유 버튼으로도\n이미지를 전달할 수 있어요',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textCaption,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // History section
              historyAsync.when(
                data: (history) {
                  if (history.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '최근 재현',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTitle,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: history.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (_, index) {
                            final rec = history[index];
                            return RecreationHistoryCard(
                              recreation: rec,
                              onTap: () => context.push(
                                '/recreation/result/${rec.id}',
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
