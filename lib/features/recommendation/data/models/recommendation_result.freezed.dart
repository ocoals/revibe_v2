// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RecommendationResult _$RecommendationResultFromJson(Map<String, dynamic> json) {
  return _RecommendationResult.fromJson(json);
}

/// @nodoc
mixin _$RecommendationResult {
  RecommendedOutfit get primary => throw _privateConstructorUsedError;
  List<RecommendedOutfit> get alternatives =>
      throw _privateConstructorUsedError;
  WeatherContext? get weather => throw _privateConstructorUsedError;

  /// Serializes this RecommendationResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecommendationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationResultCopyWith<RecommendationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationResultCopyWith<$Res> {
  factory $RecommendationResultCopyWith(
    RecommendationResult value,
    $Res Function(RecommendationResult) then,
  ) = _$RecommendationResultCopyWithImpl<$Res, RecommendationResult>;
  @useResult
  $Res call({
    RecommendedOutfit primary,
    List<RecommendedOutfit> alternatives,
    WeatherContext? weather,
  });

  $RecommendedOutfitCopyWith<$Res> get primary;
  $WeatherContextCopyWith<$Res>? get weather;
}

/// @nodoc
class _$RecommendationResultCopyWithImpl<
  $Res,
  $Val extends RecommendationResult
>
    implements $RecommendationResultCopyWith<$Res> {
  _$RecommendationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommendationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primary = null,
    Object? alternatives = null,
    Object? weather = freezed,
  }) {
    return _then(
      _value.copyWith(
            primary: null == primary
                ? _value.primary
                : primary // ignore: cast_nullable_to_non_nullable
                      as RecommendedOutfit,
            alternatives: null == alternatives
                ? _value.alternatives
                : alternatives // ignore: cast_nullable_to_non_nullable
                      as List<RecommendedOutfit>,
            weather: freezed == weather
                ? _value.weather
                : weather // ignore: cast_nullable_to_non_nullable
                      as WeatherContext?,
          )
          as $Val,
    );
  }

  /// Create a copy of RecommendationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecommendedOutfitCopyWith<$Res> get primary {
    return $RecommendedOutfitCopyWith<$Res>(_value.primary, (value) {
      return _then(_value.copyWith(primary: value) as $Val);
    });
  }

  /// Create a copy of RecommendationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeatherContextCopyWith<$Res>? get weather {
    if (_value.weather == null) {
      return null;
    }

    return $WeatherContextCopyWith<$Res>(_value.weather!, (value) {
      return _then(_value.copyWith(weather: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RecommendationResultImplCopyWith<$Res>
    implements $RecommendationResultCopyWith<$Res> {
  factory _$$RecommendationResultImplCopyWith(
    _$RecommendationResultImpl value,
    $Res Function(_$RecommendationResultImpl) then,
  ) = __$$RecommendationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    RecommendedOutfit primary,
    List<RecommendedOutfit> alternatives,
    WeatherContext? weather,
  });

  @override
  $RecommendedOutfitCopyWith<$Res> get primary;
  @override
  $WeatherContextCopyWith<$Res>? get weather;
}

/// @nodoc
class __$$RecommendationResultImplCopyWithImpl<$Res>
    extends _$RecommendationResultCopyWithImpl<$Res, _$RecommendationResultImpl>
    implements _$$RecommendationResultImplCopyWith<$Res> {
  __$$RecommendationResultImplCopyWithImpl(
    _$RecommendationResultImpl _value,
    $Res Function(_$RecommendationResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecommendationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primary = null,
    Object? alternatives = null,
    Object? weather = freezed,
  }) {
    return _then(
      _$RecommendationResultImpl(
        primary: null == primary
            ? _value.primary
            : primary // ignore: cast_nullable_to_non_nullable
                  as RecommendedOutfit,
        alternatives: null == alternatives
            ? _value._alternatives
            : alternatives // ignore: cast_nullable_to_non_nullable
                  as List<RecommendedOutfit>,
        weather: freezed == weather
            ? _value.weather
            : weather // ignore: cast_nullable_to_non_nullable
                  as WeatherContext?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationResultImpl implements _RecommendationResult {
  const _$RecommendationResultImpl({
    required this.primary,
    final List<RecommendedOutfit> alternatives = const [],
    this.weather,
  }) : _alternatives = alternatives;

  factory _$RecommendationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationResultImplFromJson(json);

  @override
  final RecommendedOutfit primary;
  final List<RecommendedOutfit> _alternatives;
  @override
  @JsonKey()
  List<RecommendedOutfit> get alternatives {
    if (_alternatives is EqualUnmodifiableListView) return _alternatives;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alternatives);
  }

  @override
  final WeatherContext? weather;

  @override
  String toString() {
    return 'RecommendationResult(primary: $primary, alternatives: $alternatives, weather: $weather)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationResultImpl &&
            (identical(other.primary, primary) || other.primary == primary) &&
            const DeepCollectionEquality().equals(
              other._alternatives,
              _alternatives,
            ) &&
            (identical(other.weather, weather) || other.weather == weather));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    primary,
    const DeepCollectionEquality().hash(_alternatives),
    weather,
  );

  /// Create a copy of RecommendationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationResultImplCopyWith<_$RecommendationResultImpl>
  get copyWith =>
      __$$RecommendationResultImplCopyWithImpl<_$RecommendationResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationResultImplToJson(this);
  }
}

abstract class _RecommendationResult implements RecommendationResult {
  const factory _RecommendationResult({
    required final RecommendedOutfit primary,
    final List<RecommendedOutfit> alternatives,
    final WeatherContext? weather,
  }) = _$RecommendationResultImpl;

  factory _RecommendationResult.fromJson(Map<String, dynamic> json) =
      _$RecommendationResultImpl.fromJson;

  @override
  RecommendedOutfit get primary;
  @override
  List<RecommendedOutfit> get alternatives;
  @override
  WeatherContext? get weather;

  /// Create a copy of RecommendationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationResultImplCopyWith<_$RecommendationResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}

RecommendedOutfit _$RecommendedOutfitFromJson(Map<String, dynamic> json) {
  return _RecommendedOutfit.fromJson(json);
}

/// @nodoc
mixin _$RecommendedOutfit {
  WardrobeItem get top => throw _privateConstructorUsedError;
  WardrobeItem get bottom => throw _privateConstructorUsedError;
  WardrobeItem? get outerwear => throw _privateConstructorUsedError;
  List<RecommendationReason> get reasons => throw _privateConstructorUsedError;

  /// Serializes this RecommendedOutfit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecommendedOutfit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendedOutfitCopyWith<RecommendedOutfit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendedOutfitCopyWith<$Res> {
  factory $RecommendedOutfitCopyWith(
    RecommendedOutfit value,
    $Res Function(RecommendedOutfit) then,
  ) = _$RecommendedOutfitCopyWithImpl<$Res, RecommendedOutfit>;
  @useResult
  $Res call({
    WardrobeItem top,
    WardrobeItem bottom,
    WardrobeItem? outerwear,
    List<RecommendationReason> reasons,
  });

  $WardrobeItemCopyWith<$Res> get top;
  $WardrobeItemCopyWith<$Res> get bottom;
  $WardrobeItemCopyWith<$Res>? get outerwear;
}

/// @nodoc
class _$RecommendedOutfitCopyWithImpl<$Res, $Val extends RecommendedOutfit>
    implements $RecommendedOutfitCopyWith<$Res> {
  _$RecommendedOutfitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommendedOutfit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? top = null,
    Object? bottom = null,
    Object? outerwear = freezed,
    Object? reasons = null,
  }) {
    return _then(
      _value.copyWith(
            top: null == top
                ? _value.top
                : top // ignore: cast_nullable_to_non_nullable
                      as WardrobeItem,
            bottom: null == bottom
                ? _value.bottom
                : bottom // ignore: cast_nullable_to_non_nullable
                      as WardrobeItem,
            outerwear: freezed == outerwear
                ? _value.outerwear
                : outerwear // ignore: cast_nullable_to_non_nullable
                      as WardrobeItem?,
            reasons: null == reasons
                ? _value.reasons
                : reasons // ignore: cast_nullable_to_non_nullable
                      as List<RecommendationReason>,
          )
          as $Val,
    );
  }

  /// Create a copy of RecommendedOutfit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WardrobeItemCopyWith<$Res> get top {
    return $WardrobeItemCopyWith<$Res>(_value.top, (value) {
      return _then(_value.copyWith(top: value) as $Val);
    });
  }

  /// Create a copy of RecommendedOutfit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WardrobeItemCopyWith<$Res> get bottom {
    return $WardrobeItemCopyWith<$Res>(_value.bottom, (value) {
      return _then(_value.copyWith(bottom: value) as $Val);
    });
  }

  /// Create a copy of RecommendedOutfit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WardrobeItemCopyWith<$Res>? get outerwear {
    if (_value.outerwear == null) {
      return null;
    }

    return $WardrobeItemCopyWith<$Res>(_value.outerwear!, (value) {
      return _then(_value.copyWith(outerwear: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RecommendedOutfitImplCopyWith<$Res>
    implements $RecommendedOutfitCopyWith<$Res> {
  factory _$$RecommendedOutfitImplCopyWith(
    _$RecommendedOutfitImpl value,
    $Res Function(_$RecommendedOutfitImpl) then,
  ) = __$$RecommendedOutfitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    WardrobeItem top,
    WardrobeItem bottom,
    WardrobeItem? outerwear,
    List<RecommendationReason> reasons,
  });

  @override
  $WardrobeItemCopyWith<$Res> get top;
  @override
  $WardrobeItemCopyWith<$Res> get bottom;
  @override
  $WardrobeItemCopyWith<$Res>? get outerwear;
}

/// @nodoc
class __$$RecommendedOutfitImplCopyWithImpl<$Res>
    extends _$RecommendedOutfitCopyWithImpl<$Res, _$RecommendedOutfitImpl>
    implements _$$RecommendedOutfitImplCopyWith<$Res> {
  __$$RecommendedOutfitImplCopyWithImpl(
    _$RecommendedOutfitImpl _value,
    $Res Function(_$RecommendedOutfitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecommendedOutfit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? top = null,
    Object? bottom = null,
    Object? outerwear = freezed,
    Object? reasons = null,
  }) {
    return _then(
      _$RecommendedOutfitImpl(
        top: null == top
            ? _value.top
            : top // ignore: cast_nullable_to_non_nullable
                  as WardrobeItem,
        bottom: null == bottom
            ? _value.bottom
            : bottom // ignore: cast_nullable_to_non_nullable
                  as WardrobeItem,
        outerwear: freezed == outerwear
            ? _value.outerwear
            : outerwear // ignore: cast_nullable_to_non_nullable
                  as WardrobeItem?,
        reasons: null == reasons
            ? _value._reasons
            : reasons // ignore: cast_nullable_to_non_nullable
                  as List<RecommendationReason>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendedOutfitImpl implements _RecommendedOutfit {
  const _$RecommendedOutfitImpl({
    required this.top,
    required this.bottom,
    this.outerwear,
    final List<RecommendationReason> reasons = const [],
  }) : _reasons = reasons;

  factory _$RecommendedOutfitImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendedOutfitImplFromJson(json);

  @override
  final WardrobeItem top;
  @override
  final WardrobeItem bottom;
  @override
  final WardrobeItem? outerwear;
  final List<RecommendationReason> _reasons;
  @override
  @JsonKey()
  List<RecommendationReason> get reasons {
    if (_reasons is EqualUnmodifiableListView) return _reasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reasons);
  }

  @override
  String toString() {
    return 'RecommendedOutfit(top: $top, bottom: $bottom, outerwear: $outerwear, reasons: $reasons)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendedOutfitImpl &&
            (identical(other.top, top) || other.top == top) &&
            (identical(other.bottom, bottom) || other.bottom == bottom) &&
            (identical(other.outerwear, outerwear) ||
                other.outerwear == outerwear) &&
            const DeepCollectionEquality().equals(other._reasons, _reasons));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    top,
    bottom,
    outerwear,
    const DeepCollectionEquality().hash(_reasons),
  );

  /// Create a copy of RecommendedOutfit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendedOutfitImplCopyWith<_$RecommendedOutfitImpl> get copyWith =>
      __$$RecommendedOutfitImplCopyWithImpl<_$RecommendedOutfitImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendedOutfitImplToJson(this);
  }
}

abstract class _RecommendedOutfit implements RecommendedOutfit {
  const factory _RecommendedOutfit({
    required final WardrobeItem top,
    required final WardrobeItem bottom,
    final WardrobeItem? outerwear,
    final List<RecommendationReason> reasons,
  }) = _$RecommendedOutfitImpl;

  factory _RecommendedOutfit.fromJson(Map<String, dynamic> json) =
      _$RecommendedOutfitImpl.fromJson;

  @override
  WardrobeItem get top;
  @override
  WardrobeItem get bottom;
  @override
  WardrobeItem? get outerwear;
  @override
  List<RecommendationReason> get reasons;

  /// Create a copy of RecommendedOutfit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendedOutfitImplCopyWith<_$RecommendedOutfitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecommendationReason _$RecommendationReasonFromJson(Map<String, dynamic> json) {
  return _RecommendationReason.fromJson(json);
}

/// @nodoc
mixin _$RecommendationReason {
  String get itemId => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Serializes this RecommendationReason to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecommendationReason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationReasonCopyWith<RecommendationReason> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationReasonCopyWith<$Res> {
  factory $RecommendationReasonCopyWith(
    RecommendationReason value,
    $Res Function(RecommendationReason) then,
  ) = _$RecommendationReasonCopyWithImpl<$Res, RecommendationReason>;
  @useResult
  $Res call({String itemId, String reason, String type});
}

/// @nodoc
class _$RecommendationReasonCopyWithImpl<
  $Res,
  $Val extends RecommendationReason
>
    implements $RecommendationReasonCopyWith<$Res> {
  _$RecommendationReasonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommendationReason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? reason = null,
    Object? type = null,
  }) {
    return _then(
      _value.copyWith(
            itemId: null == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                      as String,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecommendationReasonImplCopyWith<$Res>
    implements $RecommendationReasonCopyWith<$Res> {
  factory _$$RecommendationReasonImplCopyWith(
    _$RecommendationReasonImpl value,
    $Res Function(_$RecommendationReasonImpl) then,
  ) = __$$RecommendationReasonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String itemId, String reason, String type});
}

/// @nodoc
class __$$RecommendationReasonImplCopyWithImpl<$Res>
    extends _$RecommendationReasonCopyWithImpl<$Res, _$RecommendationReasonImpl>
    implements _$$RecommendationReasonImplCopyWith<$Res> {
  __$$RecommendationReasonImplCopyWithImpl(
    _$RecommendationReasonImpl _value,
    $Res Function(_$RecommendationReasonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecommendationReason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? reason = null,
    Object? type = null,
  }) {
    return _then(
      _$RecommendationReasonImpl(
        itemId: null == itemId
            ? _value.itemId
            : itemId // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationReasonImpl implements _RecommendationReason {
  const _$RecommendationReasonImpl({
    required this.itemId,
    required this.reason,
    required this.type,
  });

  factory _$RecommendationReasonImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationReasonImplFromJson(json);

  @override
  final String itemId;
  @override
  final String reason;
  @override
  final String type;

  @override
  String toString() {
    return 'RecommendationReason(itemId: $itemId, reason: $reason, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationReasonImpl &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, itemId, reason, type);

  /// Create a copy of RecommendationReason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationReasonImplCopyWith<_$RecommendationReasonImpl>
  get copyWith =>
      __$$RecommendationReasonImplCopyWithImpl<_$RecommendationReasonImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationReasonImplToJson(this);
  }
}

abstract class _RecommendationReason implements RecommendationReason {
  const factory _RecommendationReason({
    required final String itemId,
    required final String reason,
    required final String type,
  }) = _$RecommendationReasonImpl;

  factory _RecommendationReason.fromJson(Map<String, dynamic> json) =
      _$RecommendationReasonImpl.fromJson;

  @override
  String get itemId;
  @override
  String get reason;
  @override
  String get type;

  /// Create a copy of RecommendationReason
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationReasonImplCopyWith<_$RecommendationReasonImpl>
  get copyWith => throw _privateConstructorUsedError;
}

WeatherContext _$WeatherContextFromJson(Map<String, dynamic> json) {
  return _WeatherContext.fromJson(json);
}

/// @nodoc
mixin _$WeatherContext {
  double get temperature => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get iconCode => throw _privateConstructorUsedError;
  String get cityName => throw _privateConstructorUsedError;
  bool get needsOuterwear => throw _privateConstructorUsedError;
  List<String> get matchingSeasons => throw _privateConstructorUsedError;

  /// Serializes this WeatherContext to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherContextCopyWith<WeatherContext> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherContextCopyWith<$Res> {
  factory $WeatherContextCopyWith(
    WeatherContext value,
    $Res Function(WeatherContext) then,
  ) = _$WeatherContextCopyWithImpl<$Res, WeatherContext>;
  @useResult
  $Res call({
    double temperature,
    String description,
    String iconCode,
    String cityName,
    bool needsOuterwear,
    List<String> matchingSeasons,
  });
}

/// @nodoc
class _$WeatherContextCopyWithImpl<$Res, $Val extends WeatherContext>
    implements $WeatherContextCopyWith<$Res> {
  _$WeatherContextCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? description = null,
    Object? iconCode = null,
    Object? cityName = null,
    Object? needsOuterwear = null,
    Object? matchingSeasons = null,
  }) {
    return _then(
      _value.copyWith(
            temperature: null == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                      as double,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            iconCode: null == iconCode
                ? _value.iconCode
                : iconCode // ignore: cast_nullable_to_non_nullable
                      as String,
            cityName: null == cityName
                ? _value.cityName
                : cityName // ignore: cast_nullable_to_non_nullable
                      as String,
            needsOuterwear: null == needsOuterwear
                ? _value.needsOuterwear
                : needsOuterwear // ignore: cast_nullable_to_non_nullable
                      as bool,
            matchingSeasons: null == matchingSeasons
                ? _value.matchingSeasons
                : matchingSeasons // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherContextImplCopyWith<$Res>
    implements $WeatherContextCopyWith<$Res> {
  factory _$$WeatherContextImplCopyWith(
    _$WeatherContextImpl value,
    $Res Function(_$WeatherContextImpl) then,
  ) = __$$WeatherContextImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double temperature,
    String description,
    String iconCode,
    String cityName,
    bool needsOuterwear,
    List<String> matchingSeasons,
  });
}

/// @nodoc
class __$$WeatherContextImplCopyWithImpl<$Res>
    extends _$WeatherContextCopyWithImpl<$Res, _$WeatherContextImpl>
    implements _$$WeatherContextImplCopyWith<$Res> {
  __$$WeatherContextImplCopyWithImpl(
    _$WeatherContextImpl _value,
    $Res Function(_$WeatherContextImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? description = null,
    Object? iconCode = null,
    Object? cityName = null,
    Object? needsOuterwear = null,
    Object? matchingSeasons = null,
  }) {
    return _then(
      _$WeatherContextImpl(
        temperature: null == temperature
            ? _value.temperature
            : temperature // ignore: cast_nullable_to_non_nullable
                  as double,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        iconCode: null == iconCode
            ? _value.iconCode
            : iconCode // ignore: cast_nullable_to_non_nullable
                  as String,
        cityName: null == cityName
            ? _value.cityName
            : cityName // ignore: cast_nullable_to_non_nullable
                  as String,
        needsOuterwear: null == needsOuterwear
            ? _value.needsOuterwear
            : needsOuterwear // ignore: cast_nullable_to_non_nullable
                  as bool,
        matchingSeasons: null == matchingSeasons
            ? _value._matchingSeasons
            : matchingSeasons // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherContextImpl implements _WeatherContext {
  const _$WeatherContextImpl({
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.cityName,
    required this.needsOuterwear,
    required final List<String> matchingSeasons,
  }) : _matchingSeasons = matchingSeasons;

  factory _$WeatherContextImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherContextImplFromJson(json);

  @override
  final double temperature;
  @override
  final String description;
  @override
  final String iconCode;
  @override
  final String cityName;
  @override
  final bool needsOuterwear;
  final List<String> _matchingSeasons;
  @override
  List<String> get matchingSeasons {
    if (_matchingSeasons is EqualUnmodifiableListView) return _matchingSeasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_matchingSeasons);
  }

  @override
  String toString() {
    return 'WeatherContext(temperature: $temperature, description: $description, iconCode: $iconCode, cityName: $cityName, needsOuterwear: $needsOuterwear, matchingSeasons: $matchingSeasons)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherContextImpl &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.iconCode, iconCode) ||
                other.iconCode == iconCode) &&
            (identical(other.cityName, cityName) ||
                other.cityName == cityName) &&
            (identical(other.needsOuterwear, needsOuterwear) ||
                other.needsOuterwear == needsOuterwear) &&
            const DeepCollectionEquality().equals(
              other._matchingSeasons,
              _matchingSeasons,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    temperature,
    description,
    iconCode,
    cityName,
    needsOuterwear,
    const DeepCollectionEquality().hash(_matchingSeasons),
  );

  /// Create a copy of WeatherContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherContextImplCopyWith<_$WeatherContextImpl> get copyWith =>
      __$$WeatherContextImplCopyWithImpl<_$WeatherContextImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherContextImplToJson(this);
  }
}

abstract class _WeatherContext implements WeatherContext {
  const factory _WeatherContext({
    required final double temperature,
    required final String description,
    required final String iconCode,
    required final String cityName,
    required final bool needsOuterwear,
    required final List<String> matchingSeasons,
  }) = _$WeatherContextImpl;

  factory _WeatherContext.fromJson(Map<String, dynamic> json) =
      _$WeatherContextImpl.fromJson;

  @override
  double get temperature;
  @override
  String get description;
  @override
  String get iconCode;
  @override
  String get cityName;
  @override
  bool get needsOuterwear;
  @override
  List<String> get matchingSeasons;

  /// Create a copy of WeatherContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherContextImplCopyWith<_$WeatherContextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
