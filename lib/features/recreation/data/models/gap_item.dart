import 'package:freezed_annotation/freezed_annotation.dart';

part 'gap_item.freezed.dart';
part 'gap_item.g.dart';

@freezed
class GapItem with _$GapItem {
  const factory GapItem({
    @JsonKey(name: 'ref_index') required int refIndex,
    required String category,
    required String description,
    @JsonKey(name: 'search_keywords') required String searchKeywords,
    required Map<String, String> deeplinks,
  }) = _GapItem;

  factory GapItem.fromJson(Map<String, dynamic> json) =>
      _$GapItemFromJson(json);
}
