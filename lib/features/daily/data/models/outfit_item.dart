import 'package:freezed_annotation/freezed_annotation.dart';

part 'outfit_item.freezed.dart';
part 'outfit_item.g.dart';

@freezed
class OutfitItem with _$OutfitItem {
  const factory OutfitItem({
    @JsonKey(name: 'outfit_id') required String outfitId,
    @JsonKey(name: 'item_id') required String itemId,
    @Default(0) int position,
  }) = _OutfitItem;

  factory OutfitItem.fromJson(Map<String, dynamic> json) =>
      _$OutfitItemFromJson(json);
}
