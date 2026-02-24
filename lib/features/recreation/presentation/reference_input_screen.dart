import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';
import '../providers/recreation_process_provider.dart';
import '../providers/usage_provider.dart';
import '../providers/recreation_provider.dart';
import 'widgets/recreation_history_card.dart';

/// Look recreation — reference image input
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
      backgroundColor: AppColors.background,
      body: Column(
          children: [
            // Header — white bg with border, extends behind status bar
            Container(
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 0.5),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Text('R', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary, fontFamily: 'Georgia')),
                    const SizedBox(width: 3),
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 4.5, height: 4.5, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary)),
                        const SizedBox(height: 2.5),
                        Container(width: 4.5, height: 4.5, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.35))),
                      ]),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '룩 재현',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTitle,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload card — tappable
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: GestureDetector(
                        onTap: () {
                          final remaining = remainingAsync.valueOrNull;
                          if (remaining == null || remaining > 0) {
                            _pickImage();
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.background,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 26,
                                  color: AppColors.textCaption,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                '사진 선택하기',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textTitle,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '갤러리에서 고르거나 직접 찍어주세요',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textCaption,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Recent section — vertical list in card
                    historyAsync.when(
                      data: (history) {
                        if (history.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '최근 분석',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textTitle,
                                    ),
                                  ),
                                  if (history.length > 3)
                                    GestureDetector(
                                      onTap: () {},
                                      child: const Text(
                                        '더보기',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textCaption,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x0A000000),
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                      spreadRadius: 0.5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: history.take(3).toList().asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final rec = entry.value;
                                    final isLast = index == (history.length > 3 ? 2 : history.length - 1);
                                    return Column(
                                      children: [
                                        RecreationHistoryCard(
                                          recreation: rec,
                                          onTap: () => context.push(
                                            '/recreation/result/${rec.id}',
                                          ),
                                        ),
                                        if (!isLast)
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 14),
                                            child: Divider(
                                              height: 0.5,
                                              color: AppColors.divider,
                                            ),
                                          ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),

                    // Remaining count — centered text
                    Padding(
                      padding: const EdgeInsets.only(top: 18, bottom: 100),
                      child: Center(
                        child: remainingAsync.when(
                          data: (remaining) => RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textCaption,
                              ),
                              children: [
                                const TextSpan(text: '이번 달 남은 횟수 '),
                                TextSpan(
                                  text: '$remaining/${AppConfig.freeRecreationMonthlyLimit}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
      ),
    );
  }
}
