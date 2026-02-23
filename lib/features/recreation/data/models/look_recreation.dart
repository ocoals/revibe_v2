import 'package:freezed_annotation/freezed_annotation.dart';
import 'reference_analysis.dart';
import 'matched_item.dart';
import 'gap_item.dart';

part 'look_recreation.freezed.dart';
part 'look_recreation.g.dart';

@freezed
class LookRecreation with _$LookRecreation {
  const factory LookRecreation({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'reference_image_url') required String referenceImageUrl,
    @JsonKey(name: 'reference_analysis') required ReferenceAnalysis referenceAnalysis,
    @JsonKey(name: 'matched_items') @Default([]) List<MatchedItem> matchedItems,
    @JsonKey(name: 'gap_items') @Default([]) List<GapItem> gapItems,
    @JsonKey(name: 'overall_score') @Default(0) int overallScore,
    @Default('completed') String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _LookRecreation;

  factory LookRecreation.fromJson(Map<String, dynamic> json) =>
      _$LookRecreationFromJson(json);
}
