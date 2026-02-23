// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detected_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DetectedItemImpl _$$DetectedItemImplFromJson(Map<String, dynamic> json) =>
    _$DetectedItemImpl(
      index: (json['index'] as num).toInt(),
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      colorHex: json['color_hex'] as String,
      colorName: json['color_name'] as String,
      colorHsl: Map<String, int>.from(json['color_hsl'] as Map),
      style:
          (json['style'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      fit: json['fit'] as String?,
      pattern: json['pattern'] as String?,
      isSelected: json['isSelected'] as bool? ?? true,
    );

Map<String, dynamic> _$$DetectedItemImplToJson(_$DetectedItemImpl instance) =>
    <String, dynamic>{
      'index': instance.index,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'color_hex': instance.colorHex,
      'color_name': instance.colorName,
      'color_hsl': instance.colorHsl,
      'style': instance.style,
      'fit': instance.fit,
      'pattern': instance.pattern,
      'isSelected': instance.isSelected,
    };
