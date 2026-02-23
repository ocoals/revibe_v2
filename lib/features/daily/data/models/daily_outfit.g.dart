// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_outfit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyOutfitImpl _$$DailyOutfitImplFromJson(Map<String, dynamic> json) =>
    _$DailyOutfitImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      outfitDate: DateTime.parse(json['outfit_date'] as String),
      imageUrl: json['image_url'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$DailyOutfitImplToJson(_$DailyOutfitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'outfit_date': instance.outfitDate.toIso8601String(),
      'image_url': instance.imageUrl,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
    };
