// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'look_recreation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LookRecreationImpl _$$LookRecreationImplFromJson(Map<String, dynamic> json) =>
    _$LookRecreationImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      referenceImageUrl: json['reference_image_url'] as String,
      referenceAnalysis: ReferenceAnalysis.fromJson(
        json['reference_analysis'] as Map<String, dynamic>,
      ),
      matchedItems:
          (json['matched_items'] as List<dynamic>?)
              ?.map((e) => MatchedItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      gapItems:
          (json['gap_items'] as List<dynamic>?)
              ?.map((e) => GapItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      overallScore: (json['overall_score'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$LookRecreationImplToJson(
  _$LookRecreationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'reference_image_url': instance.referenceImageUrl,
  'reference_analysis': instance.referenceAnalysis,
  'matched_items': instance.matchedItems,
  'gap_items': instance.gapItems,
  'overall_score': instance.overallScore,
  'status': instance.status,
  'created_at': instance.createdAt.toIso8601String(),
};
