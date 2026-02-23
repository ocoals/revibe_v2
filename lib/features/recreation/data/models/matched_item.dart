import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../wardrobe/data/models/wardrobe_item.dart';

part 'matched_item.freezed.dart';
part 'matched_item.g.dart';

@freezed
class MatchedItem with _$MatchedItem {
  const factory MatchedItem({
    @JsonKey(name: 'ref_index') required int refIndex,
    @JsonKey(name: 'wardrobe_item') required WardrobeItem wardrobeItem,
    required int score,
    required ScoreBreakdown breakdown,
    @JsonKey(name: 'match_reasons') @Default([]) List<String> matchReasons,
  }) = _MatchedItem;

  factory MatchedItem.fromJson(Map<String, dynamic> json) =>
      _$MatchedItemFromJson(json);
}

@freezed
class ScoreBreakdown with _$ScoreBreakdown {
  const factory ScoreBreakdown({
    required int category,
    required int color,
    required int style,
    required int bonus,
  }) = _ScoreBreakdown;

  factory ScoreBreakdown.fromJson(Map<String, dynamic> json) =>
      _$ScoreBreakdownFromJson(json);
}
