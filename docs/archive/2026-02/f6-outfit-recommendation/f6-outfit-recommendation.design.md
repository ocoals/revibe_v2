# Design: F6 - Outfit Recommendation (기본 코디 추천)

> **Feature:** f6-outfit-recommendation
> **Phase:** Design
> **Created:** 2026-02-23
> **Status:** Draft
> **Plan Reference:** [f6-outfit-recommendation.plan.md](../../01-plan/features/f6-outfit-recommendation.plan.md)

---

## 1. Data Models (Client - Dart)

All models follow the existing `WardrobeItem` pattern: `@freezed` + `@JsonKey(name:)` for snake_case DB mapping.

### 1.1 Weather

```dart
// lib/core/models/weather.dart

/// Weather data from OpenWeatherMap API.
/// Not a Freezed model — simple immutable class (no DB mapping needed).
class Weather {
  final double temperature;      // °C
  final int weatherCode;         // OpenWeatherMap weather condition code
  final String description;      // e.g. "맑음", "흐림", "비"
  final String iconCode;         // e.g. "01d", "10n"
  final double? rainProbability; // 0.0 ~ 1.0 (nullable if not available)
  final String cityName;
  final DateTime fetchedAt;

  const Weather({
    required this.temperature,
    required this.weatherCode,
    required this.description,
    required this.iconCode,
    this.rainProbability,
    required this.cityName,
    required this.fetchedAt,
  });

  /// Parse from OpenWeatherMap Current Weather API JSON response.
  factory Weather.fromOwmJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weatherList = json['weather'] as List;
    final weather = weatherList.first as Map<String, dynamic>;

    return Weather(
      temperature: (main['temp'] as num).toDouble(),
      weatherCode: weather['id'] as int,
      description: _mapWeatherDescription(weather['id'] as int),
      iconCode: weather['icon'] as String,
      rainProbability: null, // Current Weather API doesn't include pop
      cityName: json['name'] as String,
      fetchedAt: DateTime.now(),
    );
  }

  /// Whether this cached weather data is still fresh (< 30 minutes old).
  bool get isFresh =>
      DateTime.now().difference(fetchedAt).inMinutes < 30;

  /// OpenWeatherMap icon URL.
  String get iconUrl =>
      'https://openweathermap.org/img/wn/$iconCode@2x.png';

  /// Map OWM weather code to Korean description.
  static String _mapWeatherDescription(int code) {
    if (code >= 200 && code < 300) return '뇌우';
    if (code >= 300 && code < 400) return '이슬비';
    if (code >= 500 && code < 600) return '비';
    if (code >= 600 && code < 700) return '눈';
    if (code >= 700 && code < 800) return '안개';
    if (code == 800) return '맑음';
    if (code > 800) return '흐림';
    return '알 수 없음';
  }
}
```

### 1.2 RecommendationResult

```dart
// lib/features/recommendation/data/models/recommendation_result.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../wardrobe/data/models/wardrobe_item.dart';

part 'recommendation_result.freezed.dart';
part 'recommendation_result.g.dart';

@freezed
class RecommendationResult with _$RecommendationResult {
  const factory RecommendationResult({
    required RecommendedOutfit primary,
    @Default([]) List<RecommendedOutfit> alternatives,
    WeatherContext? weather,
  }) = _RecommendationResult;

  factory RecommendationResult.fromJson(Map<String, dynamic> json) =>
      _$RecommendationResultFromJson(json);
}

@freezed
class RecommendedOutfit with _$RecommendedOutfit {
  const factory RecommendedOutfit({
    required WardrobeItem top,
    required WardrobeItem bottom,
    WardrobeItem? outerwear,
    @Default([]) List<RecommendationReason> reasons,
  }) = _RecommendedOutfit;

  factory RecommendedOutfit.fromJson(Map<String, dynamic> json) =>
      _$RecommendedOutfitFromJson(json);
}

@freezed
class RecommendationReason with _$RecommendationReason {
  const factory RecommendationReason({
    required String itemId,
    required String reason,   // e.g. "14일 미착용", "오늘 날씨에 딱!"
    required String type,     // "freshness", "weather", "variety"
  }) = _RecommendationReason;

  factory RecommendationReason.fromJson(Map<String, dynamic> json) =>
      _$RecommendationReasonFromJson(json);
}

@freezed
class WeatherContext with _$WeatherContext {
  const factory WeatherContext({
    required double temperature,
    required String description,
    required String iconCode,
    required String cityName,
    required bool needsOuterwear,
    required List<String> matchingSeasons,
  }) = _WeatherContext;

  factory WeatherContext.fromJson(Map<String, dynamic> json) =>
      _$WeatherContextFromJson(json);
}
```

---

## 2. Database Schema

**새 테이블 없음.** 기존 테이블만 활용:

- `wardrobe_items` — season, wear_count, last_worn_at 필드 활용
- `daily_outfits` + `outfit_items` — 최근 7일 착용 이력 조회

### Entity Relationships (Read-only)

```
[WardrobeItem]  ← READ (season filter + scoring)
       │
       └── wear_count, last_worn_at → freshness_score
       └── season → 시즌 필터

[DailyOutfit] + [OutfitItem]  ← READ (최근 7일)
       │
       └── recent item_ids → variety_score
```

---

## 3. WeatherService

```dart
// lib/core/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const _defaultCity = 'Seoul';

  /// API key stored in app config (not hardcoded).
  /// Will be injected via environment or Supabase remote config.
  final String _apiKey;

  Weather? _cache;

  WeatherService({required String apiKey}) : _apiKey = apiKey;

  /// Get current weather. Returns cached data if < 30 min old.
  Future<Weather?> getCurrentWeather({String? city}) async {
    // Return cache if fresh
    if (_cache != null && _cache!.isFresh) {
      return _cache;
    }

    try {
      final targetCity = city ?? _defaultCity;
      final uri = Uri.parse(
        '$_baseUrl/weather?q=$targetCity&appid=$_apiKey&units=metric&lang=kr',
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _cache = Weather.fromOwmJson(json);
        return _cache;
      }

      return _cache; // Return stale cache on error
    } catch (_) {
      return _cache; // Return stale cache on network error
    }
  }

  /// Clear cached weather data.
  void clearCache() {
    _cache = null;
  }
}
```

---

## 4. RecommendationEngine

```dart
// lib/features/recommendation/data/recommendation_engine.dart
import 'dart:math';
import '../../../core/models/weather.dart';
import '../../wardrobe/data/models/wardrobe_item.dart';
import 'models/recommendation_result.dart';

class RecommendationEngine {
  final Random _random = Random();

  /// Generate outfit recommendations based on weather and wardrobe.
  ///
  /// Returns null if insufficient items (need >= 1 top + 1 bottom).
  RecommendationResult? recommend({
    required List<WardrobeItem> wardrobeItems,
    required List<String> recentWornItemIds,  // item IDs worn in last 7 days
    required Map<String, int> recentWornCounts, // itemId -> times worn in 7 days
    Weather? weather,
  }) {
    // 1. Determine weather context
    final weatherCtx = _buildWeatherContext(weather);
    final seasons = weatherCtx?.matchingSeasons ?? ['spring', 'summer', 'fall', 'winter'];
    final needsOuterwear = weatherCtx?.needsOuterwear ?? false;

    // 2. Filter by season + active items only
    final activeItems = wardrobeItems.where((i) => i.isActive).toList();

    final tops = _filterByCategoyAndSeason(activeItems, 'tops', seasons);
    final bottoms = _filterByCategoyAndSeason(activeItems, 'bottoms', seasons);
    final outerwearList = needsOuterwear
        ? _filterByCategoyAndSeason(activeItems, 'outerwear', seasons)
        : <WardrobeItem>[];

    // Also include dresses as alternative to top+bottom
    // (Phase 2 consideration)

    // 3. Need at least 1 top + 1 bottom
    if (tops.isEmpty || bottoms.isEmpty) return null;

    // 4. Score and sort each category
    final scoredTops = _scoreAndSort(tops, recentWornItemIds, recentWornCounts);
    final scoredBottoms = _scoreAndSort(bottoms, recentWornItemIds, recentWornCounts);
    final scoredOuterwear = outerwearList.isNotEmpty
        ? _scoreAndSort(outerwearList, recentWornItemIds, recentWornCounts)
        : <_ScoredItem>[];

    // 5. Build primary outfit
    final primary = _buildOutfit(
      scoredTops, scoredBottoms, scoredOuterwear,
      index: 0, weather: weather,
    );

    // 6. Build up to 2 alternative outfits
    final alternatives = <RecommendedOutfit>[];
    for (var i = 1; i <= 2; i++) {
      final alt = _buildOutfit(
        scoredTops, scoredBottoms, scoredOuterwear,
        index: i, weather: weather,
      );
      if (alt != null) alternatives.add(alt);
    }

    return RecommendationResult(
      primary: primary!,
      alternatives: alternatives,
      weather: weatherCtx,
    );
  }

  // --- Private helpers ---

  WeatherContext? _buildWeatherContext(Weather? weather) {
    if (weather == null) return null;

    final temp = weather.temperature;
    final List<String> seasons;
    final bool needsOuterwear;

    if (temp >= 28) {
      seasons = ['summer'];
      needsOuterwear = false;
    } else if (temp >= 20) {
      seasons = ['spring', 'fall'];
      needsOuterwear = false;
    } else if (temp >= 15) {
      seasons = ['spring', 'fall'];
      needsOuterwear = false; // optional, but not forced
    } else if (temp >= 10) {
      seasons = ['fall', 'winter'];
      needsOuterwear = true;
    } else if (temp >= 5) {
      seasons = ['winter'];
      needsOuterwear = true;
    } else {
      seasons = ['winter'];
      needsOuterwear = true;
    }

    return WeatherContext(
      temperature: temp,
      description: weather.description,
      iconCode: weather.iconCode,
      cityName: weather.cityName,
      needsOuterwear: needsOuterwear,
      matchingSeasons: seasons,
    );
  }

  List<WardrobeItem> _filterByCategoyAndSeason(
    List<WardrobeItem> items,
    String category,
    List<String> seasons,
  ) {
    return items.where((item) {
      if (item.category != category) return false;
      // Check if any of the item's seasons match the target seasons
      return item.season.any((s) => seasons.contains(s));
    }).toList();
  }

  List<_ScoredItem> _scoreAndSort(
    List<WardrobeItem> items,
    List<String> recentWornIds,
    Map<String, int> recentWornCounts,
  ) {
    final scored = items.map((item) {
      final score = _calculateScore(item, recentWornIds, recentWornCounts);
      return _ScoredItem(item: item, score: score);
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }

  double _calculateScore(
    WardrobeItem item,
    List<String> recentWornIds,
    Map<String, int> recentWornCounts,
  ) {
    // Freshness score (0~50): prefer items not worn recently
    double freshnessScore;
    if (item.lastWornAt == null) {
      freshnessScore = 50.0; // Never worn = max freshness
    } else {
      final daysSince = DateTime.now().difference(item.lastWornAt!).inDays;
      freshnessScore = (daysSince / 30.0 * 50.0).clamp(0.0, 50.0);
    }

    // Variety score (0~30): penalize items worn in last 7 days
    double varietyScore;
    final recentCount = recentWornCounts[item.id] ?? 0;
    if (recentCount == 0) {
      varietyScore = 30.0;
    } else if (recentCount == 1) {
      varietyScore = 10.0;
    } else {
      varietyScore = 0.0;
    }

    // Random bonus (0~20): prevent same recommendation every time
    final randomBonus = _random.nextDouble() * 20.0;

    return freshnessScore + varietyScore + randomBonus;
  }

  RecommendedOutfit? _buildOutfit(
    List<_ScoredItem> tops,
    List<_ScoredItem> bottoms,
    List<_ScoredItem> outerwear, {
    required int index,
    Weather? weather,
  }) {
    if (index >= tops.length || index >= bottoms.length) return null;

    final top = tops[index].item;
    final bottom = bottoms[index].item;
    final outer = (outerwear.isNotEmpty && index < outerwear.length)
        ? outerwear[index].item
        : null;

    // Color clash check: if top and bottom have very similar colors, try next
    if (_isSameColorFamily(top.colorHex, bottom.colorHex) &&
        index + 1 < bottoms.length) {
      final altBottom = bottoms[index + 1].item;
      if (!_isSameColorFamily(top.colorHex, altBottom.colorHex)) {
        return _buildOutfitWithReasons(top, altBottom, outer, weather);
      }
    }

    return _buildOutfitWithReasons(top, bottom, outer, weather);
  }

  RecommendedOutfit _buildOutfitWithReasons(
    WardrobeItem top,
    WardrobeItem bottom,
    WardrobeItem? outerwear,
    Weather? weather,
  ) {
    final reasons = <RecommendationReason>[];

    // Add reasons for each item
    for (final item in [top, bottom, if (outerwear != null) outerwear]) {
      if (item.lastWornAt == null) {
        reasons.add(RecommendationReason(
          itemId: item.id,
          reason: '아직 한 번도 안 입었어요!',
          type: 'freshness',
        ));
      } else {
        final days = DateTime.now().difference(item.lastWornAt!).inDays;
        if (days >= 7) {
          reasons.add(RecommendationReason(
            itemId: item.id,
            reason: '${days}일 미착용',
            type: 'freshness',
          ));
        }
      }
    }

    if (weather != null) {
      reasons.add(RecommendationReason(
        itemId: '',
        reason: '${weather.temperature.round()}°C ${weather.description}에 딱!',
        type: 'weather',
      ));
    }

    return RecommendedOutfit(
      top: top,
      bottom: bottom,
      outerwear: outerwear,
      reasons: reasons,
    );
  }

  /// Simple color family check based on hex hue.
  /// Returns true if two colors are in the same broad family.
  bool _isSameColorFamily(String hex1, String hex2) {
    try {
      final h1 = _hexToHue(hex1);
      final h2 = _hexToHue(hex2);
      return (h1 - h2).abs() < 30; // Within 30° hue = same family
    } catch (_) {
      return false;
    }
  }

  double _hexToHue(String hex) {
    final clean = hex.replaceAll('#', '');
    final r = int.parse(clean.substring(0, 2), radix: 16) / 255.0;
    final g = int.parse(clean.substring(2, 4), radix: 16) / 255.0;
    final b = int.parse(clean.substring(4, 6), radix: 16) / 255.0;

    final maxC = [r, g, b].reduce(max);
    final minC = [r, g, b].reduce(min);
    if (maxC == minC) return 0;

    double hue;
    if (maxC == r) {
      hue = 60 * (((g - b) / (maxC - minC)) % 6);
    } else if (maxC == g) {
      hue = 60 * (((b - r) / (maxC - minC)) + 2);
    } else {
      hue = 60 * (((r - g) / (maxC - minC)) + 4);
    }

    return hue < 0 ? hue + 360 : hue;
  }
}

class _ScoredItem {
  final WardrobeItem item;
  final double score;

  const _ScoredItem({required this.item, required this.score});
}
```

---

## 5. Providers (Client - Riverpod)

### 5.1 Weather Provider

```dart
// lib/features/recommendation/providers/weather_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/weather.dart';
import '../../../core/services/weather_service.dart';

/// Weather service singleton.
/// API key should come from app config / environment.
final weatherServiceProvider = Provider<WeatherService>((ref) {
  // TODO: Replace with actual API key from env/config
  return WeatherService(apiKey: const String.fromEnvironment('OWM_API_KEY'));
});

/// Current weather data (auto-cached 30 min by WeatherService).
final currentWeatherProvider = FutureProvider<Weather?>((ref) async {
  final service = ref.watch(weatherServiceProvider);
  return service.getCurrentWeather();
});
```

### 5.2 Recommendation Provider

```dart
// lib/features/recommendation/providers/recommendation_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../daily/data/daily_repository.dart';
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
  // 1. Get all wardrobe items (unfiltered)
  final items = await ref.watch(wardrobeItemsProvider.future);

  // 2. Get weather (nullable — works without it)
  final weather = await ref.watch(currentWeatherProvider.future);

  // 3. Get recent 7 days of daily outfit records for variety scoring
  final repo = ref.watch(dailyRepositoryProvider);
  final now = DateTime.now();
  final recentItemIds = <String>[];
  final recentWornCounts = <String, int>{};

  for (var i = 0; i < 7; i++) {
    final date = now.subtract(Duration(days: i));
    final detail = await repo.fetchOutfitWithItems(date: date);
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
final currentRecommendedOutfitProvider =
    Provider<RecommendedOutfit?>((ref) {
  final result = ref.watch(todayRecommendationProvider).valueOrNull;
  if (result == null) return null;

  final index = ref.watch(recommendationIndexProvider);
  if (index == 0) return result.primary;
  if (index - 1 < result.alternatives.length) {
    return result.alternatives[index - 1];
  }
  return result.primary; // Wrap around
});
```

---

## 6. UI Design

### 6.1 RecommendedOutfitCard (홈 화면 삽입 위젯)

**Layout:**
```
┌──────────────────────────────────────┐
│ 오늘의 추천 코디                       │
│ ☀️ 5°C 서울 · 맑음                    │  ← 날씨 정보
├──────────────────────────────────────┤
│                                      │
│  ┌──────┐  ┌──────┐  ┌──────┐      │
│  │ 🖼   │  │ 🖼   │  │ 🖼   │      │  ← 추천 아이템 (가로 배치)
│  │ 상의  │  │ 하의  │  │아우터│      │     CachedNetworkImage
│  └──────┘  └──────┘  └──────┘      │
│                                      │
│  💡 14일 미착용 · 오늘 날씨에 딱!      │  ← 추천 근거 뱃지
│                                      │
│  [이 코디로 기록]    [다른 추천 ›]     │  ← CTA 버튼
└──────────────────────────────────────┘
```

```dart
// lib/features/recommendation/presentation/widgets/recommended_outfit_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../daily/data/daily_repository.dart';
import '../../../daily/providers/daily_provider.dart';
import '../../../wardrobe/data/models/wardrobe_item.dart';
import '../../providers/recommendation_provider.dart';
import '../../providers/weather_provider.dart';
import '../../data/models/recommendation_result.dart';

class RecommendedOutfitCard extends ConsumerWidget {
  const RecommendedOutfitCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recAsync = ref.watch(todayRecommendationProvider);
    final weatherAsync = ref.watch(currentWeatherProvider);

    return recAsync.when(
      loading: () => _buildShimmer(),
      error: (_, __) => const SizedBox.shrink(),
      data: (result) {
        if (result == null) return _buildEmptyState(context);

        final outfit = ref.watch(currentRecommendedOutfitProvider);
        if (outfit == null) return const SizedBox.shrink();

        final weather = weatherAsync.valueOrNull;
        final weatherCtx = result.weather;
        final totalCount = 1 + result.alternatives.length;
        final currentIndex = ref.watch(recommendationIndexProvider);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: title + weather
              _buildHeader(weatherCtx),
              const SizedBox(height: 16),

              // Item cards (horizontal)
              _buildItemRow(outfit),
              const SizedBox(height: 12),

              // Reason badges
              if (outfit.reasons.isNotEmpty) ...[
                _buildReasons(outfit.reasons),
                const SizedBox(height: 12),
              ],

              // CTA buttons
              _buildActions(context, ref, outfit, currentIndex, totalCount),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(WeatherContext? weather) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '오늘의 추천 코디',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textTitle,
          ),
        ),
        if (weather != null)
          Row(
            children: [
              Image.network(
                'https://openweathermap.org/img/wn/${weather.iconCode}@2x.png',
                width: 28,
                height: 28,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              Text(
                '${weather.temperature.round()}°C ${weather.cityName}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textCaption,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildItemRow(RecommendedOutfit outfit) {
    final items = [
      outfit.top,
      outfit.bottom,
      if (outfit.outerwear != null) outfit.outerwear!,
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _ItemThumbnail(item: item),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReasons(List<RecommendationReason> reasons) {
    // Show up to 2 reason badges
    final displayed = reasons.take(2).toList();
    return Wrap(
      spacing: 8,
      children: displayed.map((r) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.tagBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            r.reason,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.tagText,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    RecommendedOutfit outfit,
    int currentIndex,
    int totalCount,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _saveAsDaily(context, ref, outfit),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('이 코디로 기록'),
          ),
        ),
        if (totalCount > 1) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              final next = (currentIndex + 1) % totalCount;
              ref.read(recommendationIndexProvider.notifier).state = next;
            },
            child: const Text(
              '다른 추천 ›',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ],
    );
  }

  /// Save recommended outfit as today's daily record.
  Future<void> _saveAsDaily(
    BuildContext context,
    WidgetRef ref,
    RecommendedOutfit outfit,
  ) async {
    final repo = ref.read(dailyRepositoryProvider);
    final itemIds = [
      outfit.top.id,
      outfit.bottom.id,
      if (outfit.outerwear != null) outfit.outerwear!.id,
    ];

    try {
      await repo.saveOutfit(
        date: DateTime.now(),
        itemIds: itemIds,
        notes: '추천 코디로 기록',
      );

      // Invalidate related providers
      final now = DateTime.now();
      final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      ref.invalidate(monthlyOutfitsProvider(monthKey));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('오늘 코디가 기록되었어요!')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기록에 실패했어요. 다시 시도해주세요.')),
        );
      }
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.checkroom, color: AppColors.primary, size: 32),
          const SizedBox(height: 8),
          const Text(
            '옷장에 아이템을 추가하면\n코디를 추천해드려요!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.push(AppRoutes.wardrobeAdd),
            child: const Text('아이템 추가하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.chipInactive,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

/// Individual item thumbnail in the recommendation card.
class _ItemThumbnail extends StatelessWidget {
  const _ItemThumbnail({required this.item});

  final WardrobeItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.chipInactive,
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.chipInactive,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.subcategory ?? item.category,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textCaption,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
```

### 6.2 HomeScreen Integration

```dart
// lib/features/home/presentation/home_screen.dart
// Insert RecommendedOutfitCard after Quick Actions section:

// (existing) Quick Actions
// (existing) SliverToBoxAdapter with Row of _QuickActionButton

// NEW: Recommended Outfit Card
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
    child: RecommendedOutfitCard(),
  ),
),

// (existing) 내 옷장 section...
```

---

## 7. Navigation Flow

```
홈 화면
  │
  ├── RecommendedOutfitCard (자동 표시)
  │     ├── [이 코디로 기록] → DailyRepository.saveOutfit() → SnackBar
  │     ├── [다른 추천 ›] → recommendationIndexProvider 변경
  │     └── (빈 상태) → [아이템 추가하기] → /wardrobe/add
  │
  └── (no new routes needed)
```

**라우트 변경 없음.** 추천 카드는 홈 화면에 inline으로 삽입되며, "이 코디로 기록"은 API 호출만 수행 (화면 전환 없음).

---

## 8. Error Handling

| Error | Trigger | User Message | UI Action |
|-------|---------|-------------|-----------|
| 날씨 API 실패 | 네트워크/API 에러 | (없음 — 날씨 없이 추천) | 날씨 영역 숨김 |
| 아이템 부족 | tops < 1 또는 bottoms < 1 | "옷장에 아이템을 추가하면 코디를 추천해드려요!" | 빈 상태 카드 |
| 기록 저장 실패 | 네트워크 에러 | "기록에 실패했어요. 다시 시도해주세요." | SnackBar |
| 위치 권한 거부 | geolocator 거부 | (없음 — 서울 기본값) | 서울 날씨 표시 |

---

## 9. Dependencies

```yaml
# pubspec.yaml additions
dependencies:
  http: ^1.2.0       # 날씨 API 호출 (또는 기존 패키지 활용)
  geolocator: ^13.0.0 # 위치 권한 (Phase 2, MVP는 서울 기본)
```

**기존 패키지 재사용:**
- `flutter_riverpod` — 상태 관리
- `cached_network_image` — 아이템 이미지
- `freezed_annotation` + `json_annotation` — 모델
- `supabase_flutter` — 데일리 기록 저장

**MVP에서 geolocator 제외:** 기본 도시 '서울'로 시작. Phase 2에서 위치 기반으로 확장.

---

## 10. Implementation Order (Build Sequence)

```
Step 1: http 패키지 추가
  └─ pubspec.yaml에 http: ^1.2.0 추가

Step 2: Weather 모델
  └─ lib/core/models/weather.dart

Step 3: WeatherService
  └─ lib/core/services/weather_service.dart

Step 4: RecommendationResult 모델 (Freezed)
  └─ lib/features/recommendation/data/models/recommendation_result.dart
  └─ dart run build_runner build

Step 5: RecommendationEngine
  └─ lib/features/recommendation/data/recommendation_engine.dart

Step 6: Providers (weather + recommendation)
  └─ lib/features/recommendation/providers/weather_provider.dart
  └─ lib/features/recommendation/providers/recommendation_provider.dart

Step 7: RecommendedOutfitCard 위젯
  └─ lib/features/recommendation/presentation/widgets/recommended_outfit_card.dart

Step 8: 홈 화면에 카드 삽입
  └─ lib/features/home/presentation/home_screen.dart 수정

Step 9: flutter analyze + 검증
```

---

## 11. Key Design Decisions

| Decision | Choice | Rationale |
|---------|--------|-----------|
| 날씨 API | OpenWeatherMap Free | 무료 1,000 calls/day, 간단한 JSON 응답 |
| Weather 모델 | Plain class (non-Freezed) | DB 저장 안 함, API 응답 파싱만 필요 |
| 추천 엔진 위치 | 클라이언트 사이드 (Dart) | AI 호출 없음, 규칙 기반이므로 서버 불필요 |
| 추천 카드 위치 | 홈 화면 inline (새 화면 없음) | 매일 자연스럽게 노출, 진입 비용 0 |
| 기록 저장 | 기존 DailyRepository 재사용 | 코드 중복 방지, outfit_items 구조 동일 |
| 색상 충돌 체크 | Hue 기반 단순 비교 (30° 차이) | MVP에 적합한 복잡도, CIEDE2000은 과도 |
| 캐싱 전략 | WeatherService 내부 30분 캐시 | API 호출 최소화, 단순 구현 |
| 위치 정보 | MVP: 서울 고정, Phase 2: geolocator | 권한 요청 없이 빠른 MVP 배포 |
| 대체 추천 | 최대 3개 (primary + 2 alternatives) | 선택지 제공하되 과하지 않게 |

---

## 12. Coding Conventions (This Feature)

| Item | Convention |
|------|-----------|
| Feature 폴더 | `lib/features/recommendation/` (data/models, data/, providers/, presentation/widgets/) |
| Core 서비스 | `lib/core/services/weather_service.dart` |
| Core 모델 | `lib/core/models/weather.dart` |
| Model naming | PascalCase Freezed: `RecommendationResult`, `RecommendedOutfit` |
| File naming | snake_case: `recommendation_engine.dart`, `weather_service.dart` |
| Provider naming | camelCase + Provider: `todayRecommendationProvider`, `currentWeatherProvider` |
| Widget naming | PascalCase: `RecommendedOutfitCard`, `_ItemThumbnail` |
| DB columns | snake_case (기존 테이블 재사용) |
| State management | `FutureProvider` for data, `StateProvider` for UI state |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-02-23 | Initial draft | Claude |
