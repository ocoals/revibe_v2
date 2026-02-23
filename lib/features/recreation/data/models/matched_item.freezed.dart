// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'matched_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MatchedItem _$MatchedItemFromJson(Map<String, dynamic> json) {
  return _MatchedItem.fromJson(json);
}

/// @nodoc
mixin _$MatchedItem {
  @JsonKey(name: 'ref_index')
  int get refIndex => throw _privateConstructorUsedError;
  @JsonKey(name: 'wardrobe_item')
  WardrobeItem get wardrobeItem => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  ScoreBreakdown get breakdown => throw _privateConstructorUsedError;
  @JsonKey(name: 'match_reasons')
  List<String> get matchReasons => throw _privateConstructorUsedError;

  /// Serializes this MatchedItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchedItemCopyWith<MatchedItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchedItemCopyWith<$Res> {
  factory $MatchedItemCopyWith(
    MatchedItem value,
    $Res Function(MatchedItem) then,
  ) = _$MatchedItemCopyWithImpl<$Res, MatchedItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'ref_index') int refIndex,
    @JsonKey(name: 'wardrobe_item') WardrobeItem wardrobeItem,
    int score,
    ScoreBreakdown breakdown,
    @JsonKey(name: 'match_reasons') List<String> matchReasons,
  });

  $WardrobeItemCopyWith<$Res> get wardrobeItem;
  $ScoreBreakdownCopyWith<$Res> get breakdown;
}

/// @nodoc
class _$MatchedItemCopyWithImpl<$Res, $Val extends MatchedItem>
    implements $MatchedItemCopyWith<$Res> {
  _$MatchedItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? refIndex = null,
    Object? wardrobeItem = null,
    Object? score = null,
    Object? breakdown = null,
    Object? matchReasons = null,
  }) {
    return _then(
      _value.copyWith(
            refIndex: null == refIndex
                ? _value.refIndex
                : refIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            wardrobeItem: null == wardrobeItem
                ? _value.wardrobeItem
                : wardrobeItem // ignore: cast_nullable_to_non_nullable
                      as WardrobeItem,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            breakdown: null == breakdown
                ? _value.breakdown
                : breakdown // ignore: cast_nullable_to_non_nullable
                      as ScoreBreakdown,
            matchReasons: null == matchReasons
                ? _value.matchReasons
                : matchReasons // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of MatchedItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WardrobeItemCopyWith<$Res> get wardrobeItem {
    return $WardrobeItemCopyWith<$Res>(_value.wardrobeItem, (value) {
      return _then(_value.copyWith(wardrobeItem: value) as $Val);
    });
  }

  /// Create a copy of MatchedItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoreBreakdownCopyWith<$Res> get breakdown {
    return $ScoreBreakdownCopyWith<$Res>(_value.breakdown, (value) {
      return _then(_value.copyWith(breakdown: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchedItemImplCopyWith<$Res>
    implements $MatchedItemCopyWith<$Res> {
  factory _$$MatchedItemImplCopyWith(
    _$MatchedItemImpl value,
    $Res Function(_$MatchedItemImpl) then,
  ) = __$$MatchedItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ref_index') int refIndex,
    @JsonKey(name: 'wardrobe_item') WardrobeItem wardrobeItem,
    int score,
    ScoreBreakdown breakdown,
    @JsonKey(name: 'match_reasons') List<String> matchReasons,
  });

  @override
  $WardrobeItemCopyWith<$Res> get wardrobeItem;
  @override
  $ScoreBreakdownCopyWith<$Res> get breakdown;
}

/// @nodoc
class __$$MatchedItemImplCopyWithImpl<$Res>
    extends _$MatchedItemCopyWithImpl<$Res, _$MatchedItemImpl>
    implements _$$MatchedItemImplCopyWith<$Res> {
  __$$MatchedItemImplCopyWithImpl(
    _$MatchedItemImpl _value,
    $Res Function(_$MatchedItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? refIndex = null,
    Object? wardrobeItem = null,
    Object? score = null,
    Object? breakdown = null,
    Object? matchReasons = null,
  }) {
    return _then(
      _$MatchedItemImpl(
        refIndex: null == refIndex
            ? _value.refIndex
            : refIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        wardrobeItem: null == wardrobeItem
            ? _value.wardrobeItem
            : wardrobeItem // ignore: cast_nullable_to_non_nullable
                  as WardrobeItem,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        breakdown: null == breakdown
            ? _value.breakdown
            : breakdown // ignore: cast_nullable_to_non_nullable
                  as ScoreBreakdown,
        matchReasons: null == matchReasons
            ? _value._matchReasons
            : matchReasons // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchedItemImpl implements _MatchedItem {
  const _$MatchedItemImpl({
    @JsonKey(name: 'ref_index') required this.refIndex,
    @JsonKey(name: 'wardrobe_item') required this.wardrobeItem,
    required this.score,
    required this.breakdown,
    @JsonKey(name: 'match_reasons') final List<String> matchReasons = const [],
  }) : _matchReasons = matchReasons;

  factory _$MatchedItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchedItemImplFromJson(json);

  @override
  @JsonKey(name: 'ref_index')
  final int refIndex;
  @override
  @JsonKey(name: 'wardrobe_item')
  final WardrobeItem wardrobeItem;
  @override
  final int score;
  @override
  final ScoreBreakdown breakdown;
  final List<String> _matchReasons;
  @override
  @JsonKey(name: 'match_reasons')
  List<String> get matchReasons {
    if (_matchReasons is EqualUnmodifiableListView) return _matchReasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_matchReasons);
  }

  @override
  String toString() {
    return 'MatchedItem(refIndex: $refIndex, wardrobeItem: $wardrobeItem, score: $score, breakdown: $breakdown, matchReasons: $matchReasons)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchedItemImpl &&
            (identical(other.refIndex, refIndex) ||
                other.refIndex == refIndex) &&
            (identical(other.wardrobeItem, wardrobeItem) ||
                other.wardrobeItem == wardrobeItem) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.breakdown, breakdown) ||
                other.breakdown == breakdown) &&
            const DeepCollectionEquality().equals(
              other._matchReasons,
              _matchReasons,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    refIndex,
    wardrobeItem,
    score,
    breakdown,
    const DeepCollectionEquality().hash(_matchReasons),
  );

  /// Create a copy of MatchedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchedItemImplCopyWith<_$MatchedItemImpl> get copyWith =>
      __$$MatchedItemImplCopyWithImpl<_$MatchedItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchedItemImplToJson(this);
  }
}

abstract class _MatchedItem implements MatchedItem {
  const factory _MatchedItem({
    @JsonKey(name: 'ref_index') required final int refIndex,
    @JsonKey(name: 'wardrobe_item') required final WardrobeItem wardrobeItem,
    required final int score,
    required final ScoreBreakdown breakdown,
    @JsonKey(name: 'match_reasons') final List<String> matchReasons,
  }) = _$MatchedItemImpl;

  factory _MatchedItem.fromJson(Map<String, dynamic> json) =
      _$MatchedItemImpl.fromJson;

  @override
  @JsonKey(name: 'ref_index')
  int get refIndex;
  @override
  @JsonKey(name: 'wardrobe_item')
  WardrobeItem get wardrobeItem;
  @override
  int get score;
  @override
  ScoreBreakdown get breakdown;
  @override
  @JsonKey(name: 'match_reasons')
  List<String> get matchReasons;

  /// Create a copy of MatchedItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchedItemImplCopyWith<_$MatchedItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScoreBreakdown _$ScoreBreakdownFromJson(Map<String, dynamic> json) {
  return _ScoreBreakdown.fromJson(json);
}

/// @nodoc
mixin _$ScoreBreakdown {
  int get category => throw _privateConstructorUsedError;
  int get color => throw _privateConstructorUsedError;
  int get style => throw _privateConstructorUsedError;
  int get bonus => throw _privateConstructorUsedError;

  /// Serializes this ScoreBreakdown to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoreBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoreBreakdownCopyWith<ScoreBreakdown> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoreBreakdownCopyWith<$Res> {
  factory $ScoreBreakdownCopyWith(
    ScoreBreakdown value,
    $Res Function(ScoreBreakdown) then,
  ) = _$ScoreBreakdownCopyWithImpl<$Res, ScoreBreakdown>;
  @useResult
  $Res call({int category, int color, int style, int bonus});
}

/// @nodoc
class _$ScoreBreakdownCopyWithImpl<$Res, $Val extends ScoreBreakdown>
    implements $ScoreBreakdownCopyWith<$Res> {
  _$ScoreBreakdownCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoreBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? color = null,
    Object? style = null,
    Object? bonus = null,
  }) {
    return _then(
      _value.copyWith(
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as int,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as int,
            style: null == style
                ? _value.style
                : style // ignore: cast_nullable_to_non_nullable
                      as int,
            bonus: null == bonus
                ? _value.bonus
                : bonus // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScoreBreakdownImplCopyWith<$Res>
    implements $ScoreBreakdownCopyWith<$Res> {
  factory _$$ScoreBreakdownImplCopyWith(
    _$ScoreBreakdownImpl value,
    $Res Function(_$ScoreBreakdownImpl) then,
  ) = __$$ScoreBreakdownImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int category, int color, int style, int bonus});
}

/// @nodoc
class __$$ScoreBreakdownImplCopyWithImpl<$Res>
    extends _$ScoreBreakdownCopyWithImpl<$Res, _$ScoreBreakdownImpl>
    implements _$$ScoreBreakdownImplCopyWith<$Res> {
  __$$ScoreBreakdownImplCopyWithImpl(
    _$ScoreBreakdownImpl _value,
    $Res Function(_$ScoreBreakdownImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScoreBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? color = null,
    Object? style = null,
    Object? bonus = null,
  }) {
    return _then(
      _$ScoreBreakdownImpl(
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as int,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as int,
        style: null == style
            ? _value.style
            : style // ignore: cast_nullable_to_non_nullable
                  as int,
        bonus: null == bonus
            ? _value.bonus
            : bonus // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoreBreakdownImpl implements _ScoreBreakdown {
  const _$ScoreBreakdownImpl({
    required this.category,
    required this.color,
    required this.style,
    required this.bonus,
  });

  factory _$ScoreBreakdownImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoreBreakdownImplFromJson(json);

  @override
  final int category;
  @override
  final int color;
  @override
  final int style;
  @override
  final int bonus;

  @override
  String toString() {
    return 'ScoreBreakdown(category: $category, color: $color, style: $style, bonus: $bonus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoreBreakdownImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.style, style) || other.style == style) &&
            (identical(other.bonus, bonus) || other.bonus == bonus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, category, color, style, bonus);

  /// Create a copy of ScoreBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoreBreakdownImplCopyWith<_$ScoreBreakdownImpl> get copyWith =>
      __$$ScoreBreakdownImplCopyWithImpl<_$ScoreBreakdownImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoreBreakdownImplToJson(this);
  }
}

abstract class _ScoreBreakdown implements ScoreBreakdown {
  const factory _ScoreBreakdown({
    required final int category,
    required final int color,
    required final int style,
    required final int bonus,
  }) = _$ScoreBreakdownImpl;

  factory _ScoreBreakdown.fromJson(Map<String, dynamic> json) =
      _$ScoreBreakdownImpl.fromJson;

  @override
  int get category;
  @override
  int get color;
  @override
  int get style;
  @override
  int get bonus;

  /// Create a copy of ScoreBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoreBreakdownImplCopyWith<_$ScoreBreakdownImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
