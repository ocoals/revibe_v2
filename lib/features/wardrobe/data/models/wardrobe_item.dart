import 'package:freezed_annotation/freezed_annotation.dart';

part 'wardrobe_item.freezed.dart';
part 'wardrobe_item.g.dart';

@freezed
class WardrobeItem with _$WardrobeItem {
  const factory WardrobeItem({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'original_image_url') String? originalImageUrl,
    required String category,
    String? subcategory,
    @JsonKey(name: 'color_hex') required String colorHex,
    @JsonKey(name: 'color_name') required String colorName,
    @JsonKey(name: 'color_hsl') required Map<String, int> colorHsl,
    @JsonKey(name: 'style_tags') @Default([]) List<String> styleTags,
    String? fit,
    String? pattern,
    String? brand,
    @Default(['spring', 'summer', 'fall', 'winter']) List<String> season,
    @JsonKey(name: 'wear_count') @Default(0) int wearCount,
    @JsonKey(name: 'last_worn_at') DateTime? lastWornAt,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _WardrobeItem;

  factory WardrobeItem.fromJson(Map<String, dynamic> json) =>
      _$WardrobeItemFromJson(json);
}
