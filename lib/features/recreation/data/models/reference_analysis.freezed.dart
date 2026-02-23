// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reference_analysis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReferenceAnalysis _$ReferenceAnalysisFromJson(Map<String, dynamic> json) {
  return _ReferenceAnalysis.fromJson(json);
}

/// @nodoc
mixin _$ReferenceAnalysis {
  List<ReferenceItem> get items => throw _privateConstructorUsedError;
  @JsonKey(name: 'overall_style')
  String get overallStyle => throw _privateConstructorUsedError;
  String get occasion => throw _privateConstructorUsedError;

  /// Serializes this ReferenceAnalysis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReferenceAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReferenceAnalysisCopyWith<ReferenceAnalysis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferenceAnalysisCopyWith<$Res> {
  factory $ReferenceAnalysisCopyWith(
    ReferenceAnalysis value,
    $Res Function(ReferenceAnalysis) then,
  ) = _$ReferenceAnalysisCopyWithImpl<$Res, ReferenceAnalysis>;
  @useResult
  $Res call({
    List<ReferenceItem> items,
    @JsonKey(name: 'overall_style') String overallStyle,
    String occasion,
  });
}

/// @nodoc
class _$ReferenceAnalysisCopyWithImpl<$Res, $Val extends ReferenceAnalysis>
    implements $ReferenceAnalysisCopyWith<$Res> {
  _$ReferenceAnalysisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReferenceAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? overallStyle = null,
    Object? occasion = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ReferenceItem>,
            overallStyle: null == overallStyle
                ? _value.overallStyle
                : overallStyle // ignore: cast_nullable_to_non_nullable
                      as String,
            occasion: null == occasion
                ? _value.occasion
                : occasion // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReferenceAnalysisImplCopyWith<$Res>
    implements $ReferenceAnalysisCopyWith<$Res> {
  factory _$$ReferenceAnalysisImplCopyWith(
    _$ReferenceAnalysisImpl value,
    $Res Function(_$ReferenceAnalysisImpl) then,
  ) = __$$ReferenceAnalysisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ReferenceItem> items,
    @JsonKey(name: 'overall_style') String overallStyle,
    String occasion,
  });
}

/// @nodoc
class __$$ReferenceAnalysisImplCopyWithImpl<$Res>
    extends _$ReferenceAnalysisCopyWithImpl<$Res, _$ReferenceAnalysisImpl>
    implements _$$ReferenceAnalysisImplCopyWith<$Res> {
  __$$ReferenceAnalysisImplCopyWithImpl(
    _$ReferenceAnalysisImpl _value,
    $Res Function(_$ReferenceAnalysisImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReferenceAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? overallStyle = null,
    Object? occasion = null,
  }) {
    return _then(
      _$ReferenceAnalysisImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ReferenceItem>,
        overallStyle: null == overallStyle
            ? _value.overallStyle
            : overallStyle // ignore: cast_nullable_to_non_nullable
                  as String,
        occasion: null == occasion
            ? _value.occasion
            : occasion // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferenceAnalysisImpl implements _ReferenceAnalysis {
  const _$ReferenceAnalysisImpl({
    required final List<ReferenceItem> items,
    @JsonKey(name: 'overall_style') required this.overallStyle,
    required this.occasion,
  }) : _items = items;

  factory _$ReferenceAnalysisImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferenceAnalysisImplFromJson(json);

  final List<ReferenceItem> _items;
  @override
  List<ReferenceItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey(name: 'overall_style')
  final String overallStyle;
  @override
  final String occasion;

  @override
  String toString() {
    return 'ReferenceAnalysis(items: $items, overallStyle: $overallStyle, occasion: $occasion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferenceAnalysisImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.overallStyle, overallStyle) ||
                other.overallStyle == overallStyle) &&
            (identical(other.occasion, occasion) ||
                other.occasion == occasion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    overallStyle,
    occasion,
  );

  /// Create a copy of ReferenceAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferenceAnalysisImplCopyWith<_$ReferenceAnalysisImpl> get copyWith =>
      __$$ReferenceAnalysisImplCopyWithImpl<_$ReferenceAnalysisImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferenceAnalysisImplToJson(this);
  }
}

abstract class _ReferenceAnalysis implements ReferenceAnalysis {
  const factory _ReferenceAnalysis({
    required final List<ReferenceItem> items,
    @JsonKey(name: 'overall_style') required final String overallStyle,
    required final String occasion,
  }) = _$ReferenceAnalysisImpl;

  factory _ReferenceAnalysis.fromJson(Map<String, dynamic> json) =
      _$ReferenceAnalysisImpl.fromJson;

  @override
  List<ReferenceItem> get items;
  @override
  @JsonKey(name: 'overall_style')
  String get overallStyle;
  @override
  String get occasion;

  /// Create a copy of ReferenceAnalysis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReferenceAnalysisImplCopyWith<_$ReferenceAnalysisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReferenceItem _$ReferenceItemFromJson(Map<String, dynamic> json) {
  return _ReferenceItem.fromJson(json);
}

/// @nodoc
mixin _$ReferenceItem {
  int get index => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get subcategory => throw _privateConstructorUsedError;
  ReferenceColor get color => throw _privateConstructorUsedError;
  List<String> get style => throw _privateConstructorUsedError;
  String? get fit => throw _privateConstructorUsedError;
  String? get pattern => throw _privateConstructorUsedError;
  String? get material => throw _privateConstructorUsedError;

  /// Serializes this ReferenceItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReferenceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReferenceItemCopyWith<ReferenceItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferenceItemCopyWith<$Res> {
  factory $ReferenceItemCopyWith(
    ReferenceItem value,
    $Res Function(ReferenceItem) then,
  ) = _$ReferenceItemCopyWithImpl<$Res, ReferenceItem>;
  @useResult
  $Res call({
    int index,
    String category,
    String? subcategory,
    ReferenceColor color,
    List<String> style,
    String? fit,
    String? pattern,
    String? material,
  });

  $ReferenceColorCopyWith<$Res> get color;
}

/// @nodoc
class _$ReferenceItemCopyWithImpl<$Res, $Val extends ReferenceItem>
    implements $ReferenceItemCopyWith<$Res> {
  _$ReferenceItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReferenceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? category = null,
    Object? subcategory = freezed,
    Object? color = null,
    Object? style = null,
    Object? fit = freezed,
    Object? pattern = freezed,
    Object? material = freezed,
  }) {
    return _then(
      _value.copyWith(
            index: null == index
                ? _value.index
                : index // ignore: cast_nullable_to_non_nullable
                      as int,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            subcategory: freezed == subcategory
                ? _value.subcategory
                : subcategory // ignore: cast_nullable_to_non_nullable
                      as String?,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as ReferenceColor,
            style: null == style
                ? _value.style
                : style // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            fit: freezed == fit
                ? _value.fit
                : fit // ignore: cast_nullable_to_non_nullable
                      as String?,
            pattern: freezed == pattern
                ? _value.pattern
                : pattern // ignore: cast_nullable_to_non_nullable
                      as String?,
            material: freezed == material
                ? _value.material
                : material // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of ReferenceItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReferenceColorCopyWith<$Res> get color {
    return $ReferenceColorCopyWith<$Res>(_value.color, (value) {
      return _then(_value.copyWith(color: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReferenceItemImplCopyWith<$Res>
    implements $ReferenceItemCopyWith<$Res> {
  factory _$$ReferenceItemImplCopyWith(
    _$ReferenceItemImpl value,
    $Res Function(_$ReferenceItemImpl) then,
  ) = __$$ReferenceItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int index,
    String category,
    String? subcategory,
    ReferenceColor color,
    List<String> style,
    String? fit,
    String? pattern,
    String? material,
  });

  @override
  $ReferenceColorCopyWith<$Res> get color;
}

/// @nodoc
class __$$ReferenceItemImplCopyWithImpl<$Res>
    extends _$ReferenceItemCopyWithImpl<$Res, _$ReferenceItemImpl>
    implements _$$ReferenceItemImplCopyWith<$Res> {
  __$$ReferenceItemImplCopyWithImpl(
    _$ReferenceItemImpl _value,
    $Res Function(_$ReferenceItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReferenceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? category = null,
    Object? subcategory = freezed,
    Object? color = null,
    Object? style = null,
    Object? fit = freezed,
    Object? pattern = freezed,
    Object? material = freezed,
  }) {
    return _then(
      _$ReferenceItemImpl(
        index: null == index
            ? _value.index
            : index // ignore: cast_nullable_to_non_nullable
                  as int,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        subcategory: freezed == subcategory
            ? _value.subcategory
            : subcategory // ignore: cast_nullable_to_non_nullable
                  as String?,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as ReferenceColor,
        style: null == style
            ? _value._style
            : style // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        fit: freezed == fit
            ? _value.fit
            : fit // ignore: cast_nullable_to_non_nullable
                  as String?,
        pattern: freezed == pattern
            ? _value.pattern
            : pattern // ignore: cast_nullable_to_non_nullable
                  as String?,
        material: freezed == material
            ? _value.material
            : material // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferenceItemImpl implements _ReferenceItem {
  const _$ReferenceItemImpl({
    required this.index,
    required this.category,
    this.subcategory,
    required this.color,
    final List<String> style = const [],
    this.fit,
    this.pattern,
    this.material,
  }) : _style = style;

  factory _$ReferenceItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferenceItemImplFromJson(json);

  @override
  final int index;
  @override
  final String category;
  @override
  final String? subcategory;
  @override
  final ReferenceColor color;
  final List<String> _style;
  @override
  @JsonKey()
  List<String> get style {
    if (_style is EqualUnmodifiableListView) return _style;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_style);
  }

  @override
  final String? fit;
  @override
  final String? pattern;
  @override
  final String? material;

  @override
  String toString() {
    return 'ReferenceItem(index: $index, category: $category, subcategory: $subcategory, color: $color, style: $style, fit: $fit, pattern: $pattern, material: $material)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferenceItemImpl &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.subcategory, subcategory) ||
                other.subcategory == subcategory) &&
            (identical(other.color, color) || other.color == color) &&
            const DeepCollectionEquality().equals(other._style, _style) &&
            (identical(other.fit, fit) || other.fit == fit) &&
            (identical(other.pattern, pattern) || other.pattern == pattern) &&
            (identical(other.material, material) ||
                other.material == material));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    index,
    category,
    subcategory,
    color,
    const DeepCollectionEquality().hash(_style),
    fit,
    pattern,
    material,
  );

  /// Create a copy of ReferenceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferenceItemImplCopyWith<_$ReferenceItemImpl> get copyWith =>
      __$$ReferenceItemImplCopyWithImpl<_$ReferenceItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferenceItemImplToJson(this);
  }
}

abstract class _ReferenceItem implements ReferenceItem {
  const factory _ReferenceItem({
    required final int index,
    required final String category,
    final String? subcategory,
    required final ReferenceColor color,
    final List<String> style,
    final String? fit,
    final String? pattern,
    final String? material,
  }) = _$ReferenceItemImpl;

  factory _ReferenceItem.fromJson(Map<String, dynamic> json) =
      _$ReferenceItemImpl.fromJson;

  @override
  int get index;
  @override
  String get category;
  @override
  String? get subcategory;
  @override
  ReferenceColor get color;
  @override
  List<String> get style;
  @override
  String? get fit;
  @override
  String? get pattern;
  @override
  String? get material;

  /// Create a copy of ReferenceItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReferenceItemImplCopyWith<_$ReferenceItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReferenceColor _$ReferenceColorFromJson(Map<String, dynamic> json) {
  return _ReferenceColor.fromJson(json);
}

/// @nodoc
mixin _$ReferenceColor {
  String get hex => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  Map<String, int> get hsl => throw _privateConstructorUsedError;

  /// Serializes this ReferenceColor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReferenceColor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReferenceColorCopyWith<ReferenceColor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferenceColorCopyWith<$Res> {
  factory $ReferenceColorCopyWith(
    ReferenceColor value,
    $Res Function(ReferenceColor) then,
  ) = _$ReferenceColorCopyWithImpl<$Res, ReferenceColor>;
  @useResult
  $Res call({String hex, String name, Map<String, int> hsl});
}

/// @nodoc
class _$ReferenceColorCopyWithImpl<$Res, $Val extends ReferenceColor>
    implements $ReferenceColorCopyWith<$Res> {
  _$ReferenceColorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReferenceColor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? hex = null, Object? name = null, Object? hsl = null}) {
    return _then(
      _value.copyWith(
            hex: null == hex
                ? _value.hex
                : hex // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            hsl: null == hsl
                ? _value.hsl
                : hsl // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReferenceColorImplCopyWith<$Res>
    implements $ReferenceColorCopyWith<$Res> {
  factory _$$ReferenceColorImplCopyWith(
    _$ReferenceColorImpl value,
    $Res Function(_$ReferenceColorImpl) then,
  ) = __$$ReferenceColorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String hex, String name, Map<String, int> hsl});
}

/// @nodoc
class __$$ReferenceColorImplCopyWithImpl<$Res>
    extends _$ReferenceColorCopyWithImpl<$Res, _$ReferenceColorImpl>
    implements _$$ReferenceColorImplCopyWith<$Res> {
  __$$ReferenceColorImplCopyWithImpl(
    _$ReferenceColorImpl _value,
    $Res Function(_$ReferenceColorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReferenceColor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? hex = null, Object? name = null, Object? hsl = null}) {
    return _then(
      _$ReferenceColorImpl(
        hex: null == hex
            ? _value.hex
            : hex // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        hsl: null == hsl
            ? _value._hsl
            : hsl // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferenceColorImpl implements _ReferenceColor {
  const _$ReferenceColorImpl({
    required this.hex,
    required this.name,
    required final Map<String, int> hsl,
  }) : _hsl = hsl;

  factory _$ReferenceColorImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferenceColorImplFromJson(json);

  @override
  final String hex;
  @override
  final String name;
  final Map<String, int> _hsl;
  @override
  Map<String, int> get hsl {
    if (_hsl is EqualUnmodifiableMapView) return _hsl;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_hsl);
  }

  @override
  String toString() {
    return 'ReferenceColor(hex: $hex, name: $name, hsl: $hsl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferenceColorImpl &&
            (identical(other.hex, hex) || other.hex == hex) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._hsl, _hsl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    hex,
    name,
    const DeepCollectionEquality().hash(_hsl),
  );

  /// Create a copy of ReferenceColor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferenceColorImplCopyWith<_$ReferenceColorImpl> get copyWith =>
      __$$ReferenceColorImplCopyWithImpl<_$ReferenceColorImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferenceColorImplToJson(this);
  }
}

abstract class _ReferenceColor implements ReferenceColor {
  const factory _ReferenceColor({
    required final String hex,
    required final String name,
    required final Map<String, int> hsl,
  }) = _$ReferenceColorImpl;

  factory _ReferenceColor.fromJson(Map<String, dynamic> json) =
      _$ReferenceColorImpl.fromJson;

  @override
  String get hex;
  @override
  String get name;
  @override
  Map<String, int> get hsl;

  /// Create a copy of ReferenceColor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReferenceColorImplCopyWith<_$ReferenceColorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
