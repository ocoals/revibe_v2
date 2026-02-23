import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/daily_repository.dart';
import '../data/models/daily_outfit.dart';

/// Repository singleton
final dailyRepositoryProvider = Provider<DailyRepository>((ref) {
  return DailyRepository();
});

/// Monthly outfits for calendar (dots display)
/// Parameter: "YYYY-MM" format string
final monthlyOutfitsProvider =
    FutureProvider.family<List<DailyOutfit>, String>((ref, monthKey) async {
  final repo = ref.watch(dailyRepositoryProvider);
  final parts = monthKey.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  return repo.fetchMonthOutfits(year: year, month: month);
});

/// Single outfit with items for a specific date
/// Parameter: "YYYY-MM-DD" format string
final outfitByDateProvider =
    FutureProvider.family<DailyOutfitDetail?, String>((ref, dateStr) async {
  final repo = ref.watch(dailyRepositoryProvider);
  final date = DateTime.parse(dateStr);
  return repo.fetchOutfitWithItems(date: date);
});

/// Currently selected date on the calendar
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// Currently focused month on the calendar
final focusedMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
