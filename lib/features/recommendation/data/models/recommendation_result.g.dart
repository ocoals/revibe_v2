// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecommendationResultImpl _$$RecommendationResultImplFromJson(
  Map<String, dynamic> json,
) => _$RecommendationResultImpl(
  primary: RecommendedOutfit.fromJson(json['primary'] as Map<String, dynamic>),
  alternatives:
      (json['alternatives'] as List<dynamic>?)
          ?.map((e) => RecommendedOutfit.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  weather: json['weather'] == null
      ? null
      : WeatherContext.fromJson(json['weather'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$RecommendationResultImplToJson(
  _$RecommendationResultImpl instance,
) => <String, dynamic>{
  'primary': instance.primary,
  'alternatives': instance.alternatives,
  'weather': instance.weather,
};

_$RecommendedOutfitImpl _$$RecommendedOutfitImplFromJson(
  Map<String, dynamic> json,
) => _$RecommendedOutfitImpl(
  top: WardrobeItem.fromJson(json['top'] as Map<String, dynamic>),
  bottom: WardrobeItem.fromJson(json['bottom'] as Map<String, dynamic>),
  outerwear: json['outerwear'] == null
      ? null
      : WardrobeItem.fromJson(json['outerwear'] as Map<String, dynamic>),
  reasons:
      (json['reasons'] as List<dynamic>?)
          ?.map((e) => RecommendationReason.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$RecommendedOutfitImplToJson(
  _$RecommendedOutfitImpl instance,
) => <String, dynamic>{
  'top': instance.top,
  'bottom': instance.bottom,
  'outerwear': instance.outerwear,
  'reasons': instance.reasons,
};

_$RecommendationReasonImpl _$$RecommendationReasonImplFromJson(
  Map<String, dynamic> json,
) => _$RecommendationReasonImpl(
  itemId: json['itemId'] as String,
  reason: json['reason'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$$RecommendationReasonImplToJson(
  _$RecommendationReasonImpl instance,
) => <String, dynamic>{
  'itemId': instance.itemId,
  'reason': instance.reason,
  'type': instance.type,
};

_$WeatherContextImpl _$$WeatherContextImplFromJson(Map<String, dynamic> json) =>
    _$WeatherContextImpl(
      temperature: (json['temperature'] as num).toDouble(),
      description: json['description'] as String,
      iconCode: json['iconCode'] as String,
      cityName: json['cityName'] as String,
      needsOuterwear: json['needsOuterwear'] as bool,
      matchingSeasons: (json['matchingSeasons'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$WeatherContextImplToJson(
  _$WeatherContextImpl instance,
) => <String, dynamic>{
  'temperature': instance.temperature,
  'description': instance.description,
  'iconCode': instance.iconCode,
  'cityName': instance.cityName,
  'needsOuterwear': instance.needsOuterwear,
  'matchingSeasons': instance.matchingSeasons,
};
