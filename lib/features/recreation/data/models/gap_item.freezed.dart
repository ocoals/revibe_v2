// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gap_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GapItem _$GapItemFromJson(Map<String, dynamic> json) {
  return _GapItem.fromJson(json);
}

/// @nodoc
mixin _$GapItem {
  @JsonKey(name: 'ref_index')
  int get refIndex => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'search_keywords')
  String get searchKeywords => throw _privateConstructorUsedError;
  Map<String, String> get deeplinks => throw _privateConstructorUsedError;

  /// Serializes this GapItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GapItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GapItemCopyWith<GapItem> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GapItemCopyWith<$Res> {
  factory $GapItemCopyWith(GapItem value, $Res Function(GapItem) then) =
      _$GapItemCopyWithImpl<$Res, GapItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'ref_index') int refIndex,
    String category,
    String description,
    @JsonKey(name: 'search_keywords') String searchKeywords,
    Map<String, String> deeplinks,
  });
}

/// @nodoc
class _$GapItemCopyWithImpl<$Res, $Val extends GapItem>
    implements $GapItemCopyWith<$Res> {
  _$GapItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GapItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? refIndex = null,
    Object? category = null,
    Object? description = null,
    Object? searchKeywords = null,
    Object? deeplinks = null,
  }) {
    return _then(
      _value.copyWith(
            refIndex: null == refIndex
                ? _value.refIndex
                : refIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            searchKeywords: null == searchKeywords
                ? _value.searchKeywords
                : searchKeywords // ignore: cast_nullable_to_non_nullable
                      as String,
            deeplinks: null == deeplinks
                ? _value.deeplinks
                : deeplinks // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GapItemImplCopyWith<$Res> implements $GapItemCopyWith<$Res> {
  factory _$$GapItemImplCopyWith(
    _$GapItemImpl value,
    $Res Function(_$GapItemImpl) then,
  ) = __$$GapItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ref_index') int refIndex,
    String category,
    String description,
    @JsonKey(name: 'search_keywords') String searchKeywords,
    Map<String, String> deeplinks,
  });
}

/// @nodoc
class __$$GapItemImplCopyWithImpl<$Res>
    extends _$GapItemCopyWithImpl<$Res, _$GapItemImpl>
    implements _$$GapItemImplCopyWith<$Res> {
  __$$GapItemImplCopyWithImpl(
    _$GapItemImpl _value,
    $Res Function(_$GapItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GapItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? refIndex = null,
    Object? category = null,
    Object? description = null,
    Object? searchKeywords = null,
    Object? deeplinks = null,
  }) {
    return _then(
      _$GapItemImpl(
        refIndex: null == refIndex
            ? _value.refIndex
            : refIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        searchKeywords: null == searchKeywords
            ? _value.searchKeywords
            : searchKeywords // ignore: cast_nullable_to_non_nullable
                  as String,
        deeplinks: null == deeplinks
            ? _value._deeplinks
            : deeplinks // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GapItemImpl implements _GapItem {
  const _$GapItemImpl({
    @JsonKey(name: 'ref_index') required this.refIndex,
    required this.category,
    required this.description,
    @JsonKey(name: 'search_keywords') required this.searchKeywords,
    required final Map<String, String> deeplinks,
  }) : _deeplinks = deeplinks;

  factory _$GapItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$GapItemImplFromJson(json);

  @override
  @JsonKey(name: 'ref_index')
  final int refIndex;
  @override
  final String category;
  @override
  final String description;
  @override
  @JsonKey(name: 'search_keywords')
  final String searchKeywords;
  final Map<String, String> _deeplinks;
  @override
  Map<String, String> get deeplinks {
    if (_deeplinks is EqualUnmodifiableMapView) return _deeplinks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_deeplinks);
  }

  @override
  String toString() {
    return 'GapItem(refIndex: $refIndex, category: $category, description: $description, searchKeywords: $searchKeywords, deeplinks: $deeplinks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GapItemImpl &&
            (identical(other.refIndex, refIndex) ||
                other.refIndex == refIndex) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.searchKeywords, searchKeywords) ||
                other.searchKeywords == searchKeywords) &&
            const DeepCollectionEquality().equals(
              other._deeplinks,
              _deeplinks,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    refIndex,
    category,
    description,
    searchKeywords,
    const DeepCollectionEquality().hash(_deeplinks),
  );

  /// Create a copy of GapItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GapItemImplCopyWith<_$GapItemImpl> get copyWith =>
      __$$GapItemImplCopyWithImpl<_$GapItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GapItemImplToJson(this);
  }
}

abstract class _GapItem implements GapItem {
  const factory _GapItem({
    @JsonKey(name: 'ref_index') required final int refIndex,
    required final String category,
    required final String description,
    @JsonKey(name: 'search_keywords') required final String searchKeywords,
    required final Map<String, String> deeplinks,
  }) = _$GapItemImpl;

  factory _GapItem.fromJson(Map<String, dynamic> json) = _$GapItemImpl.fromJson;

  @override
  @JsonKey(name: 'ref_index')
  int get refIndex;
  @override
  String get category;
  @override
  String get description;
  @override
  @JsonKey(name: 'search_keywords')
  String get searchKeywords;
  @override
  Map<String, String> get deeplinks;

  /// Create a copy of GapItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GapItemImplCopyWith<_$GapItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
