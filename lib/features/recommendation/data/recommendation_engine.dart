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
    required List<String> recentWornItemIds,
    required Map<String, int> recentWornCounts,
    Weather? weather,
  }) {
    // 1. Determine weather context
    final weatherCtx = _buildWeatherContext(weather);
    final seasons = weatherCtx?.matchingSeasons ??
        ['spring', 'summer', 'fall', 'winter'];
    final needsOuterwear = weatherCtx?.needsOuterwear ?? false;

    // 2. Filter by season + active items only
    final activeItems = wardrobeItems.where((i) => i.isActive).toList();

    final tops = _filterByCategoryAndSeason(activeItems, 'tops', seasons);
    final bottoms =
        _filterByCategoryAndSeason(activeItems, 'bottoms', seasons);
    final outerwearList = needsOuterwear
        ? _filterByCategoryAndSeason(activeItems, 'outerwear', seasons)
        : <WardrobeItem>[];

    // 3. Need at least 1 top + 1 bottom
    if (tops.isEmpty || bottoms.isEmpty) return null;

    // 4. Score and sort each category
    final scoredTops =
        _scoreAndSort(tops, recentWornItemIds, recentWornCounts);
    final scoredBottoms =
        _scoreAndSort(bottoms, recentWornItemIds, recentWornCounts);
    final scoredOuterwear = outerwearList.isNotEmpty
        ? _scoreAndSort(outerwearList, recentWornItemIds, recentWornCounts)
        : <_ScoredItem>[];

    // 5. Build primary outfit
    final primary = _buildOutfit(
      scoredTops,
      scoredBottoms,
      scoredOuterwear,
      index: 0,
      weather: weather,
    );

    if (primary == null) return null;

    // 6. Build up to 2 alternative outfits
    final alternatives = <RecommendedOutfit>[];
    for (var i = 1; i <= 2; i++) {
      final alt = _buildOutfit(
        scoredTops,
        scoredBottoms,
        scoredOuterwear,
        index: i,
        weather: weather,
      );
      if (alt != null) alternatives.add(alt);
    }

    return RecommendationResult(
      primary: primary,
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
      needsOuterwear = false;
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

  List<WardrobeItem> _filterByCategoryAndSeason(
    List<WardrobeItem> items,
    String category,
    List<String> seasons,
  ) {
    return items.where((item) {
      if (item.category != category) return false;
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
      freshnessScore = 50.0;
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

    for (final item in [top, bottom, ?outerwear,]) {
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
            reason: '$days일 미착용',
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

  bool _isSameColorFamily(String hex1, String hex2) {
    try {
      final h1 = _hexToHue(hex1);
      final h2 = _hexToHue(hex2);
      return (h1 - h2).abs() < 30;
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
