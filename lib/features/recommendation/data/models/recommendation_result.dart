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
    required String reason,
    required String type,
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
