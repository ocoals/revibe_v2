import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../daily/providers/daily_provider.dart';
import '../../wardrobe/providers/wardrobe_provider.dart';
import '../data/models/recommendation_result.dart';
import '../data/recommendation_engine.dart';
import 'weather_provider.dart';

/// Recommendation engine singleton.
final recommendationEngineProvider = Provider<RecommendationEngine>((ref) {
  return RecommendationEngine();
});

/// Today's outfit recommendation.
/// Watches: wardrobe items, weather, recent daily records.
final todayRecommendationProvider =
    FutureProvider<RecommendationResult?>((ref) async {
  // 1. Get all wardrobe items
  final items = await ref.watch(wardrobeItemsProvider.future);

  // 2. Get weather (nullable — works without it)
  final weather = await ref.watch(currentWeatherProvider.future);

  // 3. Get recent 7 days of daily outfit records for variety scoring
  final dailyRepo = ref.watch(dailyRepositoryProvider);
  final now = DateTime.now();
  final recentItemIds = <String>[];
  final recentWornCounts = <String, int>{};

  for (var i = 0; i < 7; i++) {
    final date = now.subtract(Duration(days: i));
    final detail = await dailyRepo.fetchOutfitWithItems(date: date);
    if (detail != null) {
      for (final item in detail.items) {
        recentItemIds.add(item.id);
        recentWornCounts[item.id] = (recentWornCounts[item.id] ?? 0) + 1;
      }
    }
  }

  // 4. Run recommendation engine
  final engine = ref.read(recommendationEngineProvider);
  return engine.recommend(
    wardrobeItems: items,
    recentWornItemIds: recentItemIds,
    recentWornCounts: recentWornCounts,
    weather: weather,
  );
});

/// Current recommendation index (0 = primary, 1+ = alternatives).
final recommendationIndexProvider = StateProvider<int>((ref) => 0);

/// The currently displayed recommendation outfit.
final currentRecommendedOutfitProvider = Provider<RecommendedOutfit?>((ref) {
  final result = ref.watch(todayRecommendationProvider).valueOrNull;
  if (result == null) return null;

  final index = ref.watch(recommendationIndexProvider);
  if (index == 0) return result.primary;
  if (index - 1 < result.alternatives.length) {
    return result.alternatives[index - 1];
  }
  return result.primary;
});
