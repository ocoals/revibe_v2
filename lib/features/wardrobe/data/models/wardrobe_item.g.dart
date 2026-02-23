// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wardrobe_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WardrobeItemImpl _$$WardrobeItemImplFromJson(Map<String, dynamic> json) =>
    _$WardrobeItemImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      originalImageUrl: json['original_image_url'] as String?,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      colorHex: json['color_hex'] as String,
      colorName: json['color_name'] as String,
      colorHsl: Map<String, int>.from(json['color_hsl'] as Map),
      styleTags:
          (json['style_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      fit: json['fit'] as String?,
      pattern: json['pattern'] as String?,
      brand: json['brand'] as String?,
      season:
          (json['season'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['spring', 'summer', 'fall', 'winter'],
      wearCount: (json['wear_count'] as num?)?.toInt() ?? 0,
      lastWornAt: json['last_worn_at'] == null
          ? null
          : DateTime.parse(json['last_worn_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$WardrobeItemImplToJson(_$WardrobeItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'image_url': instance.imageUrl,
      'original_image_url': instance.originalImageUrl,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'color_hex': instance.colorHex,
      'color_name': instance.colorName,
      'color_hsl': instance.colorHsl,
      'style_tags': instance.styleTags,
      'fit': instance.fit,
      'pattern': instance.pattern,
      'brand': instance.brand,
      'season': instance.season,
      'wear_count': instance.wearCount,
      'last_worn_at': instance.lastWornAt?.toIso8601String(),
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
