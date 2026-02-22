import 'package:freezed_annotation/freezed_annotation.dart';

part 'wardrobe_item.freezed.dart';
part 'wardrobe_item.g.dart';

@freezed
class WardrobeItem with _$WardrobeItem {
  const factory WardrobeItem({
    required String id,
    required String userId,
    required String imageUrl,
    String? originalImageUrl,
    required String category,
    String? subcategory,
    required String colorHex,
    required String colorName,
    required Map<String, int> colorHsl,
    @Default([]) List<String> styleTags,
    String? fit,
    String? pattern,
    String? brand,
    @Default(['spring', 'summer', 'fall', 'winter']) List<String> season,
    @Default(0) int wearCount,
    DateTime? lastWornAt,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WardrobeItem;

  factory WardrobeItem.fromJson(Map<String, dynamic> json) =>
      _$WardrobeItemFromJson(json);
}
