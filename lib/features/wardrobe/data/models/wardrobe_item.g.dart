// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wardrobe_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WardrobeItemImpl _$$WardrobeItemImplFromJson(
  Map<String, dynamic> json,
) => _$WardrobeItemImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  imageUrl: json['imageUrl'] as String,
  originalImageUrl: json['originalImageUrl'] as String?,
  category: json['category'] as String,
  subcategory: json['subcategory'] as String?,
  colorHex: json['colorHex'] as String,
  colorName: json['colorName'] as String,
  colorHsl: Map<String, int>.from(json['colorHsl'] as Map),
  styleTags:
      (json['styleTags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  fit: json['fit'] as String?,
  pattern: json['pattern'] as String?,
  brand: json['brand'] as String?,
  season:
      (json['season'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const ['spring', 'summer', 'fall', 'winter'],
  wearCount: (json['wearCount'] as num?)?.toInt() ?? 0,
  lastWornAt: json['lastWornAt'] == null
      ? null
      : DateTime.parse(json['lastWornAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$WardrobeItemImplToJson(_$WardrobeItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'imageUrl': instance.imageUrl,
      'originalImageUrl': instance.originalImageUrl,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'colorHex': instance.colorHex,
      'colorName': instance.colorName,
      'colorHsl': instance.colorHsl,
      'styleTags': instance.styleTags,
      'fit': instance.fit,
      'pattern': instance.pattern,
      'brand': instance.brand,
      'season': instance.season,
      'wearCount': instance.wearCount,
      'lastWornAt': instance.lastWornAt?.toIso8601String(),
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
