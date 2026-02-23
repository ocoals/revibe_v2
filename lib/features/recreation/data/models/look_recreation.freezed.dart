// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'look_recreation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LookRecreation _$LookRecreationFromJson(Map<String, dynamic> json) {
  return _LookRecreation.fromJson(json);
}

/// @nodoc
mixin _$LookRecreation {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_image_url')
  String get referenceImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_analysis')
  ReferenceAnalysis get referenceAnalysis => throw _privateConstructorUsedError;
  @JsonKey(name: 'matched_items')
  List<MatchedItem> get matchedItems => throw _privateConstructorUsedError;
  @JsonKey(name: 'gap_items')
  List<GapItem> get gapItems => throw _privateConstructorUsedError;
  @JsonKey(name: 'overall_score')
  int get overallScore => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LookRecreation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LookRecreation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LookRecreationCopyWith<LookRecreation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LookRecreationCopyWith<$Res> {
  factory $LookRecreationCopyWith(
    LookRecreation value,
    $Res Function(LookRecreation) then,
  ) = _$LookRecreationCopyWithImpl<$Res, LookRecreation>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'reference_image_url') String referenceImageUrl,
    @JsonKey(name: 'reference_analysis') ReferenceAnalysis referenceAnalysis,
    @JsonKey(name: 'matched_items') List<MatchedItem> matchedItems,
    @JsonKey(name: 'gap_items') List<GapItem> gapItems,
    @JsonKey(name: 'overall_score') int overallScore,
    String status,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });

  $ReferenceAnalysisCopyWith<$Res> get referenceAnalysis;
}

/// @nodoc
class _$LookRecreationCopyWithImpl<$Res, $Val extends LookRecreation>
    implements $LookRecreationCopyWith<$Res> {
  _$LookRecreationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LookRecreation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? referenceImageUrl = null,
    Object? referenceAnalysis = null,
    Object? matchedItems = null,
    Object? gapItems = null,
    Object? overallScore = null,
    Object? status = null,
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
            referenceImageUrl: null == referenceImageUrl
                ? _value.referenceImageUrl
                : referenceImageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            referenceAnalysis: null == referenceAnalysis
                ? _value.referenceAnalysis
                : referenceAnalysis // ignore: cast_nullable_to_non_nullable
                      as ReferenceAnalysis,
            matchedItems: null == matchedItems
                ? _value.matchedItems
                : matchedItems // ignore: cast_nullable_to_non_nullable
                      as List<MatchedItem>,
            gapItems: null == gapItems
                ? _value.gapItems
                : gapItems // ignore: cast_nullable_to_non_nullable
                      as List<GapItem>,
            overallScore: null == overallScore
                ? _value.overallScore
                : overallScore // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of LookRecreation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReferenceAnalysisCopyWith<$Res> get referenceAnalysis {
    return $ReferenceAnalysisCopyWith<$Res>(_value.referenceAnalysis, (value) {
      return _then(_value.copyWith(referenceAnalysis: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LookRecreationImplCopyWith<$Res>
    implements $LookRecreationCopyWith<$Res> {
  factory _$$LookRecreationImplCopyWith(
    _$LookRecreationImpl value,
    $Res Function(_$LookRecreationImpl) then,
  ) = __$$LookRecreationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'reference_image_url') String referenceImageUrl,
    @JsonKey(name: 'reference_analysis') ReferenceAnalysis referenceAnalysis,
    @JsonKey(name: 'matched_items') List<MatchedItem> matchedItems,
    @JsonKey(name: 'gap_items') List<GapItem> gapItems,
    @JsonKey(name: 'overall_score') int overallScore,
    String status,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });

  @override
  $ReferenceAnalysisCopyWith<$Res> get referenceAnalysis;
}

/// @nodoc
class __$$LookRecreationImplCopyWithImpl<$Res>
    extends _$LookRecreationCopyWithImpl<$Res, _$LookRecreationImpl>
    implements _$$LookRecreationImplCopyWith<$Res> {
  __$$LookRecreationImplCopyWithImpl(
    _$LookRecreationImpl _value,
    $Res Function(_$LookRecreationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LookRecreation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? referenceImageUrl = null,
    Object? referenceAnalysis = null,
    Object? matchedItems = null,
    Object? gapItems = null,
    Object? overallScore = null,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$LookRecreationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        referenceImageUrl: null == referenceImageUrl
            ? _value.referenceImageUrl
            : referenceImageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        referenceAnalysis: null == referenceAnalysis
            ? _value.referenceAnalysis
            : referenceAnalysis // ignore: cast_nullable_to_non_nullable
                  as ReferenceAnalysis,
        matchedItems: null == matchedItems
            ? _value._matchedItems
            : matchedItems // ignore: cast_nullable_to_non_nullable
                  as List<MatchedItem>,
        gapItems: null == gapItems
            ? _value._gapItems
            : gapItems // ignore: cast_nullable_to_non_nullable
                  as List<GapItem>,
        overallScore: null == overallScore
            ? _value.overallScore
            : overallScore // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$LookRecreationImpl implements _LookRecreation {
  const _$LookRecreationImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'reference_image_url') required this.referenceImageUrl,
    @JsonKey(name: 'reference_analysis') required this.referenceAnalysis,
    @JsonKey(name: 'matched_items')
    final List<MatchedItem> matchedItems = const [],
    @JsonKey(name: 'gap_items') final List<GapItem> gapItems = const [],
    @JsonKey(name: 'overall_score') this.overallScore = 0,
    this.status = 'completed',
    @JsonKey(name: 'created_at') required this.createdAt,
  }) : _matchedItems = matchedItems,
       _gapItems = gapItems;

  factory _$LookRecreationImpl.fromJson(Map<String, dynamic> json) =>
      _$$LookRecreationImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'reference_image_url')
  final String referenceImageUrl;
  @override
  @JsonKey(name: 'reference_analysis')
  final ReferenceAnalysis referenceAnalysis;
  final List<MatchedItem> _matchedItems;
  @override
  @JsonKey(name: 'matched_items')
  List<MatchedItem> get matchedItems {
    if (_matchedItems is EqualUnmodifiableListView) return _matchedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_matchedItems);
  }

  final List<GapItem> _gapItems;
  @override
  @JsonKey(name: 'gap_items')
  List<GapItem> get gapItems {
    if (_gapItems is EqualUnmodifiableListView) return _gapItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gapItems);
  }

  @override
  @JsonKey(name: 'overall_score')
  final int overallScore;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'LookRecreation(id: $id, userId: $userId, referenceImageUrl: $referenceImageUrl, referenceAnalysis: $referenceAnalysis, matchedItems: $matchedItems, gapItems: $gapItems, overallScore: $overallScore, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LookRecreationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.referenceImageUrl, referenceImageUrl) ||
                other.referenceImageUrl == referenceImageUrl) &&
            (identical(other.referenceAnalysis, referenceAnalysis) ||
                other.referenceAnalysis == referenceAnalysis) &&
            const DeepCollectionEquality().equals(
              other._matchedItems,
              _matchedItems,
            ) &&
            const DeepCollectionEquality().equals(other._gapItems, _gapItems) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    referenceImageUrl,
    referenceAnalysis,
    const DeepCollectionEquality().hash(_matchedItems),
    const DeepCollectionEquality().hash(_gapItems),
    overallScore,
    status,
    createdAt,
  );

  /// Create a copy of LookRecreation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LookRecreationImplCopyWith<_$LookRecreationImpl> get copyWith =>
      __$$LookRecreationImplCopyWithImpl<_$LookRecreationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LookRecreationImplToJson(this);
  }
}

abstract class _LookRecreation implements LookRecreation {
  const factory _LookRecreation({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'reference_image_url')
    required final String referenceImageUrl,
    @JsonKey(name: 'reference_analysis')
    required final ReferenceAnalysis referenceAnalysis,
    @JsonKey(name: 'matched_items') final List<MatchedItem> matchedItems,
    @JsonKey(name: 'gap_items') final List<GapItem> gapItems,
    @JsonKey(name: 'overall_score') final int overallScore,
    final String status,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$LookRecreationImpl;

  factory _LookRecreation.fromJson(Map<String, dynamic> json) =
      _$LookRecreationImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'reference_image_url')
  String get referenceImageUrl;
  @override
  @JsonKey(name: 'reference_analysis')
  ReferenceAnalysis get referenceAnalysis;
  @override
  @JsonKey(name: 'matched_items')
  List<MatchedItem> get matchedItems;
  @override
  @JsonKey(name: 'gap_items')
  List<GapItem> get gapItems;
  @override
  @JsonKey(name: 'overall_score')
  int get overallScore;
  @override
  String get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of LookRecreation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LookRecreationImplCopyWith<_$LookRecreationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
