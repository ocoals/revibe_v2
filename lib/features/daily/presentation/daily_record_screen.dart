import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/date_format_utils.dart';
import '../data/daily_repository.dart';
import '../providers/daily_provider.dart';
import '../providers/daily_record_form_provider.dart';

/// S14: Daily Outfit Record Screen
class DailyRecordScreen extends ConsumerStatefulWidget {
  const DailyRecordScreen({super.key, required this.initialDate});

  final DateTime initialDate;

  @override
  ConsumerState<DailyRecordScreen> createState() => _DailyRecordScreenState();
}

class _DailyRecordScreenState extends ConsumerState<DailyRecordScreen> {
  late final TextEditingController _notesController;
  bool _existingLoaded = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Load existing record if editing
  void _loadExistingIfNeeded(DailyOutfitDetail? existing) {
    if (_existingLoaded || existing == null) return;
    _existingLoaded = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier =
          ref.read(dailyRecordFormProvider(widget.initialDate).notifier);
      notifier.loadExisting(existing.items, existing.outfit.notes);
      _notesController.text = existing.outfit.notes ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(dailyRecordFormProvider(widget.initialDate));
    final dateStr = DateFormatUtils.formatDateKey(widget.initialDate);
    final existingAsync = ref.watch(outfitByDateProvider(dateStr));

    // Load existing data on first build
    existingAsync.whenData((data) => _loadExistingIfNeeded(data));

    final formNotifier =
        ref.read(dailyRecordFormProvider(widget.initialDate).notifier);
    final dateFormat = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘 뭐 입었어?'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date selector
            GestureDetector(
              onTap: () => _pickDate(context, formNotifier),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(formState.date),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '변경',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Input method selection
            const Text(
              '어떻게 기록할까요?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textTitle,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InputMethodCard(
                    icon: Icons.checkroom,
                    label: '옷장에서 선택',
                    enabled: true,
                    onTap: () => context.push(
                      AppRoutes.dailyRecordPickItems,
                      extra: widget.initialDate,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InputMethodCard(
                    icon: Icons.camera_alt,
                    label: '지금 촬영',
                    enabled: false,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Selected items display
            if (formState.selectedItems.isNotEmpty) ...[
              Text(
                '선택된 아이템 (${formState.selectedItems.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: formState.selectedItems.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = formState.selectedItems[index];
                    return _SelectedItemChip(
                      imageUrl: item.imageUrl,
                      label: item.subcategory ?? item.category,
                      onRemove: () => formNotifier.removeItem(item.id),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Notes input
            const Text(
              '메모 (선택)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textTitle,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              onChanged: (value) => formNotifier.setNotes(value),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '오늘의 코디 한줄평...',
                hintStyle: const TextStyle(color: AppColors.textCaption),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Error message
            if (formState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  formState.errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),

            const SizedBox(height: 16),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: formState.selectedItems.isEmpty ||
                        formState.isSaving
                    ? null
                    : () => _save(formNotifier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.divider,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: formState.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '기록 저장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(
      BuildContext context, DailyRecordFormNotifier notifier) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      notifier.setDate(picked);
    }
  }

  Future<void> _save(DailyRecordFormNotifier notifier) async {
    final success = await notifier.save();
    if (success && mounted) {
      context.pop();
    }
  }

}

class _InputMethodCard extends StatelessWidget {
  const _InputMethodCard({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : AppColors.chipInactive,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: enabled ? AppColors.primary : AppColors.textCaption,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: enabled ? AppColors.textTitle : AppColors.textCaption,
              ),
            ),
            if (!enabled)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '곧 지원',
                  style: TextStyle(fontSize: 11, color: AppColors.textCaption),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectedItemChip extends StatelessWidget {
  const _SelectedItemChip({
    required this.imageUrl,
    required this.label,
    required this.onRemove,
  });

  final String imageUrl;
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    width: 64,
                    height: 64,
                    color: AppColors.chipInactive,
                  ),
                ),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textBody),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
