// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReferenceAnalysisImpl _$$ReferenceAnalysisImplFromJson(
  Map<String, dynamic> json,
) => _$ReferenceAnalysisImpl(
  items: (json['items'] as List<dynamic>)
      .map((e) => ReferenceItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  overallStyle: json['overall_style'] as String,
  occasion: json['occasion'] as String,
);

Map<String, dynamic> _$$ReferenceAnalysisImplToJson(
  _$ReferenceAnalysisImpl instance,
) => <String, dynamic>{
  'items': instance.items,
  'overall_style': instance.overallStyle,
  'occasion': instance.occasion,
};

_$ReferenceItemImpl _$$ReferenceItemImplFromJson(Map<String, dynamic> json) =>
    _$ReferenceItemImpl(
      index: (json['index'] as num).toInt(),
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      color: ReferenceColor.fromJson(json['color'] as Map<String, dynamic>),
      style:
          (json['style'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      fit: json['fit'] as String?,
      pattern: json['pattern'] as String?,
      material: json['material'] as String?,
    );

Map<String, dynamic> _$$ReferenceItemImplToJson(_$ReferenceItemImpl instance) =>
    <String, dynamic>{
      'index': instance.index,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'color': instance.color,
      'style': instance.style,
      'fit': instance.fit,
      'pattern': instance.pattern,
      'material': instance.material,
    };

_$ReferenceColorImpl _$$ReferenceColorImplFromJson(Map<String, dynamic> json) =>
    _$ReferenceColorImpl(
      hex: json['hex'] as String,
      name: json['name'] as String,
      hsl: Map<String, int>.from(json['hsl'] as Map),
    );

Map<String, dynamic> _$$ReferenceColorImplToJson(
  _$ReferenceColorImpl instance,
) => <String, dynamic>{
  'hex': instance.hex,
  'name': instance.name,
  'hsl': instance.hsl,
};
