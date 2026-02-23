// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outfit_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OutfitItemImpl _$$OutfitItemImplFromJson(Map<String, dynamic> json) =>
    _$OutfitItemImpl(
      outfitId: json['outfit_id'] as String,
      itemId: json['item_id'] as String,
      position: (json['position'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$OutfitItemImplToJson(_$OutfitItemImpl instance) =>
    <String, dynamic>{
      'outfit_id': instance.outfitId,
      'item_id': instance.itemId,
      'position': instance.position,
    };
