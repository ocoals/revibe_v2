// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matched_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchedItemImpl _$$MatchedItemImplFromJson(Map<String, dynamic> json) =>
    _$MatchedItemImpl(
      refIndex: (json['ref_index'] as num).toInt(),
      wardrobeItem: WardrobeItem.fromJson(
        json['wardrobe_item'] as Map<String, dynamic>,
      ),
      score: (json['score'] as num).toInt(),
      breakdown: ScoreBreakdown.fromJson(
        json['breakdown'] as Map<String, dynamic>,
      ),
      matchReasons:
          (json['match_reasons'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$MatchedItemImplToJson(_$MatchedItemImpl instance) =>
    <String, dynamic>{
      'ref_index': instance.refIndex,
      'wardrobe_item': instance.wardrobeItem,
      'score': instance.score,
      'breakdown': instance.breakdown,
      'match_reasons': instance.matchReasons,
    };

_$ScoreBreakdownImpl _$$ScoreBreakdownImplFromJson(Map<String, dynamic> json) =>
    _$ScoreBreakdownImpl(
      category: (json['category'] as num).toInt(),
      color: (json['color'] as num).toInt(),
      style: (json['style'] as num).toInt(),
      bonus: (json['bonus'] as num).toInt(),
    );

Map<String, dynamic> _$$ScoreBreakdownImplToJson(
  _$ScoreBreakdownImpl instance,
) => <String, dynamic>{
  'category': instance.category,
  'color': instance.color,
  'style': instance.style,
  'bonus': instance.bonus,
};
