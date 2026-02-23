import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';
import '../providers/item_registration_provider.dart';
import 'widgets/category_selector.dart';
import 'widgets/chip_option_selector.dart';
import 'widgets/color_selector.dart';

/// Metadata input form for wardrobe item registration
class ItemRegisterScreen extends ConsumerWidget {
  const ItemRegisterScreen({super.key});

  static const _fitOptions = {
    'oversized': '오버사이즈',
    'regular': '레귤러',
    'slim': '슬림',
  };

  static const _patternOptions = {
    'solid': '솔리드',
    'stripe': '스트라이프',
    'check': '체크',
    'floral': '플로럴',
    'dot': '도트',
    'print': '프린트',
    'other': '기타',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageBytes = ref.watch(pendingImageProvider);
    final state = ref.watch(itemRegistrationProvider);
    final notifier = ref.read(itemRegistrationProvider.notifier);

    if (imageBytes == null) {
      // No image, go back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('아이템 등록')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image preview
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                imageBytes,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Category (required)
          _sectionTitle('카테고리', required: true),
          const SizedBox(height: 8),
          CategorySelector(
            selected: state.category,
            onSelected: notifier.setCategory,
          ),

          // Subcategory
          if (state.category != null) ...[
            const SizedBox(height: 16),
            _sectionTitle('세부 카테고리'),
            const SizedBox(height: 8),
            SubcategorySelector(
              category: state.category!,
              selected: state.subcategory,
              onSelected: notifier.setSubcategory,
            ),
          ],
          const SizedBox(height: 24),

          // Color (required)
          _sectionTitle('색상', required: true),
          const SizedBox(height: 12),
          ColorSelector(
            selectedHex: state.colorHex,
            onSelected: notifier.setColorHex,
          ),
          const SizedBox(height: 24),

          // Fit (optional)
          _sectionTitle('핏'),
          const SizedBox(height: 8),
          ChipOptionSelector(
            options: _fitOptions,
            selected: state.fit,
            onSelected: notifier.setFit,
          ),
          const SizedBox(height: 24),

          // Pattern (optional)
          _sectionTitle('패턴'),
          const SizedBox(height: 8),
          ChipOptionSelector(
            options: _patternOptions,
            selected: state.pattern,
            onSelected: notifier.setPattern,
          ),
          const SizedBox(height: 24),

          // Brand (optional)
          _sectionTitle('브랜드'),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: '브랜드명 (선택)',
              hintStyle: TextStyle(color: AppColors.textCaption),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: notifier.setBrand,
          ),
          const SizedBox(height: 24),

          // Season (optional, multi-select)
          _sectionTitle('계절'),
          const SizedBox(height: 8),
          SeasonSelector(
            selected: state.season,
            onToggle: notifier.toggleSeason,
          ),
          const SizedBox(height: 24),

          // Error message
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                state.error!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
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
              onPressed: state.isSubmitting
                  ? null
                  : () => _submit(context, ref),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('옷장에 추가하기'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, {bool required = false}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textTitle,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final success =
        await ref.read(itemRegistrationProvider.notifier).submit();
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('아이템이 등록되었습니다!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(AppRoutes.wardrobe);
    }
  }
}
