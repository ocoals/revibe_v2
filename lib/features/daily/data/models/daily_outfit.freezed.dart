// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_outfit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailyOutfit _$DailyOutfitFromJson(Map<String, dynamic> json) {
  return _DailyOutfit.fromJson(json);
}

/// @nodoc
mixin _$DailyOutfit {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'outfit_date')
  DateTime get outfitDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this DailyOutfit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyOutfit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyOutfitCopyWith<DailyOutfit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyOutfitCopyWith<$Res> {
  factory $DailyOutfitCopyWith(
    DailyOutfit value,
    $Res Function(DailyOutfit) then,
  ) = _$DailyOutfitCopyWithImpl<$Res, DailyOutfit>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'outfit_date') DateTime outfitDate,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? notes,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$DailyOutfitCopyWithImpl<$Res, $Val extends DailyOutfit>
    implements $DailyOutfitCopyWith<$Res> {
  _$DailyOutfitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyOutfit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? outfitDate = null,
    Object? imageUrl = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            outfitDate: null == outfitDate
                ? _value.outfitDate
                : outfitDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyOutfitImplCopyWith<$Res>
    implements $DailyOutfitCopyWith<$Res> {
  factory _$$DailyOutfitImplCopyWith(
    _$DailyOutfitImpl value,
    $Res Function(_$DailyOutfitImpl) then,
  ) = __$$DailyOutfitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'outfit_date') DateTime outfitDate,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? notes,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$DailyOutfitImplCopyWithImpl<$Res>
    extends _$DailyOutfitCopyWithImpl<$Res, _$DailyOutfitImpl>
    implements _$$DailyOutfitImplCopyWith<$Res> {
  __$$DailyOutfitImplCopyWithImpl(
    _$DailyOutfitImpl _value,
    $Res Function(_$DailyOutfitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyOutfit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? outfitDate = null,
    Object? imageUrl = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$DailyOutfitImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        outfitDate: null == outfitDate
            ? _value.outfitDate
            : outfitDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyOutfitImpl implements _DailyOutfit {
  const _$DailyOutfitImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'outfit_date') required this.outfitDate,
    @JsonKey(name: 'image_url') this.imageUrl,
    this.notes,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$DailyOutfitImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyOutfitImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'outfit_date')
  final DateTime outfitDate;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'DailyOutfit(id: $id, userId: $userId, outfitDate: $outfitDate, imageUrl: $imageUrl, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyOutfitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.outfitDate, outfitDate) ||
                other.outfitDate == outfitDate) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    outfitDate,
    imageUrl,
    notes,
    createdAt,
  );

  /// Create a copy of DailyOutfit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyOutfitImplCopyWith<_$DailyOutfitImpl> get copyWith =>
      __$$DailyOutfitImplCopyWithImpl<_$DailyOutfitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyOutfitImplToJson(this);
  }
}

abstract class _DailyOutfit implements DailyOutfit {
  const factory _DailyOutfit({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'outfit_date') required final DateTime outfitDate,
    @JsonKey(name: 'image_url') final String? imageUrl,
    final String? notes,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$DailyOutfitImpl;

  factory _DailyOutfit.fromJson(Map<String, dynamic> json) =
      _$DailyOutfitImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'outfit_date')
  DateTime get outfitDate;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of DailyOutfit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyOutfitImplCopyWith<_$DailyOutfitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
