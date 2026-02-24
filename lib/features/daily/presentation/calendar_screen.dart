import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../data/daily_repository.dart';
import '../providers/daily_provider.dart';

/// Daily tab — weekly strip + outfit card + premium upsell
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final dateKey = DateFormatUtils.formatDateKey(selectedDate);
    final detailAsync = ref.watch(outfitByDateProvider(dateKey));
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
          children: [
            // Header + weekly strip — white bg, extends behind status bar
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 0.5),
                ),
              ),
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                        '데일리 코디',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTitle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Weekly calendar strip
                  _WeeklyCalendarStrip(
                    selectedDate: selectedDate,
                    onDateSelected: (date) {
                      ref.read(selectedDateProvider.notifier).state = date;
                    },
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Today's outfit card
                    detailAsync.when(
                      data: (detail) {
                        if (detail == null) {
                          return _EmptyOutfitCard(
                            date: selectedDate,
                            onRecord: () =>
                                _navigateToRecord(context, selectedDate),
                          );
                        }
                        return _OutfitCard(
                          detail: detail,
                          date: selectedDate,
                          onEdit: () =>
                              _navigateToRecord(context, selectedDate),
                          onDelete: () => _deleteOutfit(
                              context, ref, detail.outfit.id, selectedDate),
                        );
                      },
                      loading: () => Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                            child: CircularProgressIndicator()),
                      ),
                      error: (_, _) => Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            '기록을 불러올 수 없어요',
                            style:
                                TextStyle(color: AppColors.textCaption),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Premium upsell (primary solid bg, lock icon)
                    if (!isPremium)
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.paywall),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_outline,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '데일리 코디는 프리미엄 기능이에요',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '7일 무료 체험 시작하기',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white
                                            .withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
      ),
      floatingActionButton: _isToday(selectedDate)
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _navigateToRecord(context, DateTime.now()),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                '오늘 기록하기',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  void _navigateToRecord(BuildContext context, DateTime date) {
    final dateStr = DateFormatUtils.formatDateKey(date);
    context.push('${AppRoutes.dailyRecordCreate}?date=$dateStr');
  }

  Future<void> _deleteOutfit(BuildContext context, WidgetRef ref,
      String outfitId, DateTime date) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 날의 코디 기록을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(dailyRepositoryProvider);
      await repo.deleteOutfit(outfitId);

      final monthKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final dateKey = DateFormatUtils.formatDateKey(date);
      ref.invalidate(monthlyOutfitsProvider(monthKey));
      ref.invalidate(outfitByDateProvider(dateKey));
    }
  }
}

/// Weekly calendar strip — design: 32x32 circles
class _WeeklyCalendarStrip extends StatelessWidget {
  const _WeeklyCalendarStrip({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final weekStart =
        selectedDate.subtract(Duration(days: selectedDate.weekday % 7));
    final days =
        List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final dayLabels = ['일', '월', '화', '수', '목', '금', '토'];
    final today = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = days[index];
        final isSelected = date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;
        final isPast = date.isBefore(DateTime(today.year, today.month, today.day));
        final isFuture = date.isAfter(today);

        return GestureDetector(
          onTap: isFuture ? null : () => onDateSelected(date),
          child: SizedBox(
            width: 36,
            child: Column(
              children: [
                Text(
                  dayLabels[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textCaption,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isPast
                                ? AppColors.lineDark
                                : AppColors.divider,
                            width: 1.5,
                          ),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : isPast
                                ? AppColors.textTitle
                                : AppColors.mute,
                      ),
                    ),
                  ),
                ),
                // Dot marker for past days with records
                if (isPast && !isSelected)
                  Container(
                    width: 3,
                    height: 3,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  )
                else
                  const SizedBox(height: 7),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _EmptyOutfitCard extends StatelessWidget {
  const _EmptyOutfitCard({required this.date, required this.onRecord});

  final DateTime date;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        children: [
          Icon(Icons.checkroom, size: 48, color: AppColors.textCaption),
          const SizedBox(height: 12),
          Text(
            '${dateFormat.format(date)}의 코디를 기록해보세요',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textCaption,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRecord,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
            ),
            child: const Text(
              '기록하기',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutfitCard extends StatelessWidget {
  const _OutfitCard({
    required this.detail,
    required this.date,
    required this.onEdit,
    required this.onDelete,
  });

  final DailyOutfitDetail detail;
  final DateTime date;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M월 d일 EEEE', 'ko_KR');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오늘의 코디',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateFormat.format(date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textCaption,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 30),
                    ),
                    child: const Text('수정',
                        style: TextStyle(fontSize: 13)),
                  ),
                  TextButton(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 30),
                    ),
                    child: const Text('삭제',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.error)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items — 3 items horizontal
          if (detail.items.isNotEmpty)
            Row(
              children: detail.items.take(3).map((item) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        context.push('/wardrobe/${item.id}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              height: 88,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                height: 88,
                                color: AppColors.chipInactive,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.subcategory ?? item.category,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textCaption,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

          // Style tags
          if (detail.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '미니멀',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textBody),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '데일리',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textBody),
                  ),
                ),
              ],
            ),
          ],

          // Notes
          if (detail.outfit.notes != null &&
              detail.outfit.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.chipInactive,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                detail.outfit.notes!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textBody,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
