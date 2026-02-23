// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outfit_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OutfitItem _$OutfitItemFromJson(Map<String, dynamic> json) {
  return _OutfitItem.fromJson(json);
}

/// @nodoc
mixin _$OutfitItem {
  @JsonKey(name: 'outfit_id')
  String get outfitId => throw _privateConstructorUsedError;
  @JsonKey(name: 'item_id')
  String get itemId => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;

  /// Serializes this OutfitItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OutfitItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OutfitItemCopyWith<OutfitItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutfitItemCopyWith<$Res> {
  factory $OutfitItemCopyWith(
    OutfitItem value,
    $Res Function(OutfitItem) then,
  ) = _$OutfitItemCopyWithImpl<$Res, OutfitItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'outfit_id') String outfitId,
    @JsonKey(name: 'item_id') String itemId,
    int position,
  });
}

/// @nodoc
class _$OutfitItemCopyWithImpl<$Res, $Val extends OutfitItem>
    implements $OutfitItemCopyWith<$Res> {
  _$OutfitItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OutfitItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outfitId = null,
    Object? itemId = null,
    Object? position = null,
  }) {
    return _then(
      _value.copyWith(
            outfitId: null == outfitId
                ? _value.outfitId
                : outfitId // ignore: cast_nullable_to_non_nullable
                      as String,
            itemId: null == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                      as String,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OutfitItemImplCopyWith<$Res>
    implements $OutfitItemCopyWith<$Res> {
  factory _$$OutfitItemImplCopyWith(
    _$OutfitItemImpl value,
    $Res Function(_$OutfitItemImpl) then,
  ) = __$$OutfitItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'outfit_id') String outfitId,
    @JsonKey(name: 'item_id') String itemId,
    int position,
  });
}

/// @nodoc
class __$$OutfitItemImplCopyWithImpl<$Res>
    extends _$OutfitItemCopyWithImpl<$Res, _$OutfitItemImpl>
    implements _$$OutfitItemImplCopyWith<$Res> {
  __$$OutfitItemImplCopyWithImpl(
    _$OutfitItemImpl _value,
    $Res Function(_$OutfitItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OutfitItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outfitId = null,
    Object? itemId = null,
    Object? position = null,
  }) {
    return _then(
      _$OutfitItemImpl(
        outfitId: null == outfitId
            ? _value.outfitId
            : outfitId // ignore: cast_nullable_to_non_nullable
                  as String,
        itemId: null == itemId
            ? _value.itemId
            : itemId // ignore: cast_nullable_to_non_nullable
                  as String,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OutfitItemImpl implements _OutfitItem {
  const _$OutfitItemImpl({
    @JsonKey(name: 'outfit_id') required this.outfitId,
    @JsonKey(name: 'item_id') required this.itemId,
    this.position = 0,
  });

  factory _$OutfitItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$OutfitItemImplFromJson(json);

  @override
  @JsonKey(name: 'outfit_id')
  final String outfitId;
  @override
  @JsonKey(name: 'item_id')
  final String itemId;
  @override
  @JsonKey()
  final int position;

  @override
  String toString() {
    return 'OutfitItem(outfitId: $outfitId, itemId: $itemId, position: $position)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutfitItemImpl &&
            (identical(other.outfitId, outfitId) ||
                other.outfitId == outfitId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.position, position) ||
                other.position == position));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, outfitId, itemId, position);

  /// Create a copy of OutfitItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OutfitItemImplCopyWith<_$OutfitItemImpl> get copyWith =>
      __$$OutfitItemImplCopyWithImpl<_$OutfitItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OutfitItemImplToJson(this);
  }
}

abstract class _OutfitItem implements OutfitItem {
  const factory _OutfitItem({
    @JsonKey(name: 'outfit_id') required final String outfitId,
    @JsonKey(name: 'item_id') required final String itemId,
    final int position,
  }) = _$OutfitItemImpl;

  factory _OutfitItem.fromJson(Map<String, dynamic> json) =
      _$OutfitItemImpl.fromJson;

  @override
  @JsonKey(name: 'outfit_id')
  String get outfitId;
  @override
  @JsonKey(name: 'item_id')
  String get itemId;
  @override
  int get position;

  /// Create a copy of OutfitItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OutfitItemImplCopyWith<_$OutfitItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
