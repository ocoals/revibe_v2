import 'package:freezed_annotation/freezed_annotation.dart';

part 'reference_analysis.freezed.dart';
part 'reference_analysis.g.dart';

@freezed
class ReferenceAnalysis with _$ReferenceAnalysis {
  const factory ReferenceAnalysis({
    required List<ReferenceItem> items,
    @JsonKey(name: 'overall_style') required String overallStyle,
    required String occasion,
  }) = _ReferenceAnalysis;

  factory ReferenceAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ReferenceAnalysisFromJson(json);
}

@freezed
class ReferenceItem with _$ReferenceItem {
  const factory ReferenceItem({
    required int index,
    required String category,
    String? subcategory,
    required ReferenceColor color,
    @Default([]) List<String> style,
    String? fit,
    String? pattern,
    String? material,
  }) = _ReferenceItem;

  factory ReferenceItem.fromJson(Map<String, dynamic> json) =>
      _$ReferenceItemFromJson(json);
}

@freezed
class ReferenceColor with _$ReferenceColor {
  const factory ReferenceColor({
    required String hex,
    required String name,
    required Map<String, int> hsl,
  }) = _ReferenceColor;

  factory ReferenceColor.fromJson(Map<String, dynamic> json) =>
      _$ReferenceColorFromJson(json);
}
