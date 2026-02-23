import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/background_removal_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../wardrobe/providers/wardrobe_provider.dart';
import '../providers/onboarding_analyze_provider.dart';
import 'widgets/detected_item_card.dart';

/// S04: Onboarding item confirmation screen
class ConfirmScreen extends ConsumerStatefulWidget {
  const ConfirmScreen({super.key});

  @override
  ConsumerState<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends ConsumerState<ConfirmScreen> {
  bool _isSaving = false;

  Future<void> _saveAndComplete() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final analyzeState = ref.read(onboardingAnalyzeProvider);
    final selectedItems = analyzeState.selectedItems;
    if (selectedItems.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(wardrobeRepositoryProvider);
      final bgService = ref.read(backgroundRemovalServiceProvider);
      final imageBytes = analyzeState.imageBytes;

      // Remove background and upload processed image
      String? imageUrl;
      if (imageBytes != null) {
        final bgResult = await bgService.removeBackground(imageBytes);
        if (bgResult.usedFallback) {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          imageUrl = await repo.uploadImage(user.id, bgResult.imageBytes, fileName);
        } else {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_processed.png';
          imageUrl = await repo.uploadProcessedImage(
            user.id, bgResult.imageBytes, fileName,
          );
        }
      }

      // Save each selected item to wardrobe
      for (final item in selectedItems) {
        final data = <String, dynamic>{
          'user_id': user.id,
          'image_url': imageUrl ?? '',
          'category': item.category,
          'subcategory': item.subcategory,
          'color_hex': item.colorHex,
          'color_name': item.colorName,
          'color_hsl': item.colorHsl,
          'fit': item.fit,
          'pattern': item.pattern,
          'style_tags': item.style,
        };
        await repo.createItem(data);
      }

      // Invalidate wardrobe providers
      ref.invalidate(wardrobeItemsProvider);
      ref.invalidate(wardrobeCountProvider);
      ref.invalidate(canAddItemProvider);

      // Mark onboarding complete
      await _completeOnboarding();

      // Reset provider
      ref.read(onboardingAnalyzeProvider.notifier).reset();

      if (mounted) {
        _showRecreationPrompt();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('저장에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _completeOnboarding() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user != null) {
      try {
        await SupabaseConfig.client.from('profiles').update({
          'onboarding_completed': true,
        }).eq('id', user.id);
      } catch (_) {}
    }
    markOnboardingCompleted();
  }

  void _showRecreationPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '옷장에 추가했어요!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textTitle,
          ),
        ),
        content: Text(
          '인플루언서 룩을 내 옷으로\n재현해볼까요?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textBody,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (context.mounted) context.go(AppRoutes.home);
            },
            child: Text(
              '나중에',
              style: TextStyle(color: AppColors.textCaption),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (context.mounted) context.go(AppRoutes.recreation);
            },
            child: const Text('룩 재현하기'),
          ),
        ],
      ),
    );
  }

  Future<void> _skipOnboarding() async {
    await _completeOnboarding();
    ref.read(onboardingAnalyzeProvider.notifier).reset();
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final analyzeState = ref.watch(onboardingAnalyzeProvider);
    final notifier = ref.read(onboardingAnalyzeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('아이템 확인'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _skipOnboarding,
            child: Text(
              '건너뛰기',
              style: TextStyle(color: AppColors.textCaption),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(analyzeState, notifier),
      ),
    );
  }

  Widget _buildBody(
    OnboardingAnalyzeState state,
    OnboardingAnalyzeNotifier notifier,
  ) {
    switch (state.step) {
      case OnboardingAnalyzeStep.idle:
        return const Center(child: Text('이미지를 선택해주세요'));

      case OnboardingAnalyzeStep.analyzing:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'AI가 옷을 분석하고 있어요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '잠시만 기다려주세요...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textBody,
                ),
              ),
            ],
          ),
        );

      case OnboardingAnalyzeStep.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _getErrorMessage(state.errorCode),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTitle,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('다시 촬영하기'),
                ),
              ],
            ),
          ),
        );

      case OnboardingAnalyzeStep.completed:
        return _buildCompletedView(state, notifier);
    }
  }

  Widget _buildCompletedView(
    OnboardingAnalyzeState state,
    OnboardingAnalyzeNotifier notifier,
  ) {
    final selectedCount = state.selectedItems.length;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Text(
                '${state.items.length}개 아이템을 찾았어요!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '카테고리를 확인하고 옷장에 추가해보세요',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textBody,
                ),
              ),
              const SizedBox(height: 16),

              // Original image thumbnail
              if (state.imageBytes != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      state.imageBytes!,
                      width: 120,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Items count
              Text(
                '${state.items.length}개 아이템 감지 ($selectedCount개 선택됨)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBody,
                ),
              ),
              const SizedBox(height: 12),

              // Detected items list
              ...state.items.map((item) => DetectedItemCard(
                    item: item,
                    onToggle: () => notifier.toggleItem(item.index),
                    onCategoryChanged: (cat) =>
                        notifier.updateCategory(item.index, cat),
                  )),
            ],
          ),
        ),

        // Bottom CTA
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border(
              top: BorderSide(color: AppColors.divider),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    (_isSaving || selectedCount == 0) ? null : _saveAndComplete,
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('옷장에 추가하기 ($selectedCount)'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getErrorMessage(String? code) {
    return switch (code) {
      'NO_FASHION_ITEMS' => '패션 아이템을 찾지 못했어요.\n전신이 보이는 사진으로 다시 시도해보세요.',
      'AUTH_REQUIRED' => '로그인이 필요합니다.',
      _ => '분석 중 오류가 발생했어요.\n다시 시도해주세요.',
    };
  }
}
