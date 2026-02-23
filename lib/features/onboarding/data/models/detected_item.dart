import 'package:freezed_annotation/freezed_annotation.dart';

part 'detected_item.freezed.dart';
part 'detected_item.g.dart';

@freezed
class DetectedItem with _$DetectedItem {
  const factory DetectedItem({
    required int index,
    required String category,
    String? subcategory,
    @JsonKey(name: 'color_hex') required String colorHex,
    @JsonKey(name: 'color_name') required String colorName,
    @JsonKey(name: 'color_hsl') required Map<String, int> colorHsl,
    @Default([]) List<String> style,
    String? fit,
    String? pattern,
    @Default(true) bool isSelected,
  }) = _DetectedItem;

  factory DetectedItem.fromJson(Map<String, dynamic> json) =>
      _$DetectedItemFromJson(json);

  /// Parse from Claude analysis response where color is a nested object
  factory DetectedItem.fromAnalysisJson(Map<String, dynamic> json) {
    final color = json['color'] as Map<String, dynamic>? ?? {};
    final hsl = color['hsl'] as Map<String, dynamic>? ?? {};

    return DetectedItem(
      index: json['index'] as int? ?? 0,
      category: json['category'] as String? ?? 'tops',
      subcategory: json['subcategory'] as String?,
      colorHex: color['hex'] as String? ?? '#000000',
      colorName: color['name'] as String? ?? '',
      colorHsl: {
        'h': (hsl['h'] as num?)?.toInt() ?? 0,
        's': (hsl['s'] as num?)?.toInt() ?? 0,
        'l': (hsl['l'] as num?)?.toInt() ?? 0,
      },
      style: (json['style'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      fit: json['fit'] as String?,
      pattern: json['pattern'] as String?,
      isSelected: true,
    );
  }
}
