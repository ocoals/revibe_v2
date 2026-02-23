import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_outfit.freezed.dart';
part 'daily_outfit.g.dart';

@freezed
class DailyOutfit with _$DailyOutfit {
  const factory DailyOutfit({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'outfit_date') required DateTime outfitDate,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _DailyOutfit;

  factory DailyOutfit.fromJson(Map<String, dynamic> json) =>
      _$DailyOutfitFromJson(json);
}
