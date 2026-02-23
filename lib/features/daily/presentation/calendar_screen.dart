import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/date_format_utils.dart';
import '../data/daily_repository.dart';
import '../providers/daily_provider.dart';

/// S15: Calendar Screen - monthly view with outfit dots
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedMonth = ref.watch(focusedMonthProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final monthKey =
        '${focusedMonth.year}-${focusedMonth.month.toString().padLeft(2, '0')}';
    final monthOutfitsAsync = ref.watch(monthlyOutfitsProvider(monthKey));
    final dateKey = DateFormatUtils.formatDateKey(selectedDate);
    final detailAsync = ref.watch(outfitByDateProvider(dateKey));

    // Collect dates that have outfits for dot markers
    final recordedDates = <DateTime>{};
    monthOutfitsAsync.whenData((outfits) {
      for (final outfit in outfits) {
        recordedDates.add(DateTime(
          outfit.outfitDate.year,
          outfit.outfitDate.month,
          outfit.outfitDate.day,
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('코디 기록'),
      ),
      body: Column(
        children: [
          // Calendar
          TableCalendar(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime.now(),
            focusedDay: focusedMonth,
            selectedDayPredicate: (day) => isSameDay(selectedDate, day),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: '월간',
            },
            locale: 'ko_KR',
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textTitle,
              ),
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: AppColors.textBody),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: AppColors.textBody),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textCaption),
              weekendStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textCaption),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(color: AppColors.primary),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
              defaultTextStyle:
                  const TextStyle(fontSize: 14, color: AppColors.textTitle),
              weekendTextStyle:
                  const TextStyle(fontSize: 14, color: AppColors.textBody),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, _) {
                final normalizedDate =
                    DateTime(date.year, date.month, date.day);
                if (recordedDates.contains(normalizedDate)) {
                  return Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            onDaySelected: (selectedDay, focusedDay) {
              ref.read(selectedDateProvider.notifier).state = selectedDay;
              ref.read(focusedMonthProvider.notifier).state = focusedDay;
            },
            onPageChanged: (focusedDay) {
              ref.read(focusedMonthProvider.notifier).state = focusedDay;
            },
          ),
          const Divider(height: 1),

          // Detail section
          Expanded(
            child: detailAsync.when(
              data: (detail) {
                if (detail == null) {
                  return _EmptyDayView(
                    date: selectedDate,
                    onRecord: () => _navigateToRecord(context, selectedDate),
                  );
                }
                return _OutfitDetailView(
                  detail: detail,
                  date: selectedDate,
                  onEdit: () => _navigateToRecord(context, selectedDate),
                  onDelete: () =>
                      _deleteOutfit(context, ref, detail.outfit.id, selectedDate),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Center(
                child: Text(
                  '기록을 불러올 수 없어요',
                  style: TextStyle(color: AppColors.textCaption),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _shouldShowFab(selectedDate)
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToRecord(context, DateTime.now()),
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

  bool _shouldShowFab(DateTime selectedDate) {
    final today = DateTime.now();
    return selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;
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
            child:
                const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(dailyRepositoryProvider);
      await repo.deleteOutfit(outfitId);

      // Invalidate providers
      final monthKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final dateKey = DateFormatUtils.formatDateKey(date);
      ref.invalidate(monthlyOutfitsProvider(monthKey));
      ref.invalidate(outfitByDateProvider(dateKey));
    }
  }

}

class _EmptyDayView extends StatelessWidget {
  const _EmptyDayView({required this.date, required this.onRecord});

  final DateTime date;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

class _OutfitDetailView extends StatelessWidget {
  const _OutfitDetailView({
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
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${dateFormat.format(date)} 코디',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTitle,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: onEdit,
                    child: const Text('수정'),
                  ),
                  TextButton(
                    onPressed: onDelete,
                    child: const Text(
                      '삭제',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items horizontal scroll
          if (detail.items.isNotEmpty)
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: detail.items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = detail.items[index];
                  return GestureDetector(
                    onTap: () =>
                        context.push('/wardrobe/${item.id}'),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: item.imageUrl,
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
                        const SizedBox(height: 4),
                        Text(
                          item.subcategory ?? item.category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textBody,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Notes
          if (detail.outfit.notes != null &&
              detail.outfit.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
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
