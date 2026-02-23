// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gap_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GapItemImpl _$$GapItemImplFromJson(Map<String, dynamic> json) =>
    _$GapItemImpl(
      refIndex: (json['ref_index'] as num).toInt(),
      category: json['category'] as String,
      description: json['description'] as String,
      searchKeywords: json['search_keywords'] as String,
      deeplinks: Map<String, String>.from(json['deeplinks'] as Map),
    );

Map<String, dynamic> _$$GapItemImplToJson(_$GapItemImpl instance) =>
    <String, dynamic>{
      'ref_index': instance.refIndex,
      'category': instance.category,
      'description': instance.description,
      'search_keywords': instance.searchKeywords,
      'deeplinks': instance.deeplinks,
    };
