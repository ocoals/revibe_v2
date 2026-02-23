// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detected_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DetectedItem _$DetectedItemFromJson(Map<String, dynamic> json) {
  return _DetectedItem.fromJson(json);
}

/// @nodoc
mixin _$DetectedItem {
  int get index => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get subcategory => throw _privateConstructorUsedError;
  @JsonKey(name: 'color_hex')
  String get colorHex => throw _privateConstructorUsedError;
  @JsonKey(name: 'color_name')
  String get colorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'color_hsl')
  Map<String, int> get colorHsl => throw _privateConstructorUsedError;
  List<String> get style => throw _privateConstructorUsedError;
  String? get fit => throw _privateConstructorUsedError;
  String? get pattern => throw _privateConstructorUsedError;
  bool get isSelected => throw _privateConstructorUsedError;

  /// Serializes this DetectedItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DetectedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DetectedItemCopyWith<DetectedItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetectedItemCopyWith<$Res> {
  factory $DetectedItemCopyWith(
    DetectedItem value,
    $Res Function(DetectedItem) then,
  ) = _$DetectedItemCopyWithImpl<$Res, DetectedItem>;
  @useResult
  $Res call({
    int index,
    String category,
    String? subcategory,
    @JsonKey(name: 'color_hex') String colorHex,
    @JsonKey(name: 'color_name') String colorName,
    @JsonKey(name: 'color_hsl') Map<String, int> colorHsl,
    List<String> style,
    String? fit,
    String? pattern,
    bool isSelected,
  });
}

/// @nodoc
class _$DetectedItemCopyWithImpl<$Res, $Val extends DetectedItem>
    implements $DetectedItemCopyWith<$Res> {
  _$DetectedItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DetectedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? category = null,
    Object? subcategory = freezed,
    Object? colorHex = null,
    Object? colorName = null,
    Object? colorHsl = null,
    Object? style = null,
    Object? fit = freezed,
    Object? pattern = freezed,
    Object? isSelected = null,
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
            colorHex: null == colorHex
                ? _value.colorHex
                : colorHex // ignore: cast_nullable_to_non_nullable
                      as String,
            colorName: null == colorName
                ? _value.colorName
                : colorName // ignore: cast_nullable_to_non_nullable
                      as String,
            colorHsl: null == colorHsl
                ? _value.colorHsl
                : colorHsl // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
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
            isSelected: null == isSelected
                ? _value.isSelected
                : isSelected // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DetectedItemImplCopyWith<$Res>
    implements $DetectedItemCopyWith<$Res> {
  factory _$$DetectedItemImplCopyWith(
    _$DetectedItemImpl value,
    $Res Function(_$DetectedItemImpl) then,
  ) = __$$DetectedItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int index,
    String category,
    String? subcategory,
    @JsonKey(name: 'color_hex') String colorHex,
    @JsonKey(name: 'color_name') String colorName,
    @JsonKey(name: 'color_hsl') Map<String, int> colorHsl,
    List<String> style,
    String? fit,
    String? pattern,
    bool isSelected,
  });
}

/// @nodoc
class __$$DetectedItemImplCopyWithImpl<$Res>
    extends _$DetectedItemCopyWithImpl<$Res, _$DetectedItemImpl>
    implements _$$DetectedItemImplCopyWith<$Res> {
  __$$DetectedItemImplCopyWithImpl(
    _$DetectedItemImpl _value,
    $Res Function(_$DetectedItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DetectedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? category = null,
    Object? subcategory = freezed,
    Object? colorHex = null,
    Object? colorName = null,
    Object? colorHsl = null,
    Object? style = null,
    Object? fit = freezed,
    Object? pattern = freezed,
    Object? isSelected = null,
  }) {
    return _then(
      _$DetectedItemImpl(
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
        colorHex: null == colorHex
            ? _value.colorHex
            : colorHex // ignore: cast_nullable_to_non_nullable
                  as String,
        colorName: null == colorName
            ? _value.colorName
            : colorName // ignore: cast_nullable_to_non_nullable
                  as String,
        colorHsl: null == colorHsl
            ? _value._colorHsl
            : colorHsl // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
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
        isSelected: null == isSelected
            ? _value.isSelected
            : isSelected // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DetectedItemImpl implements _DetectedItem {
  const _$DetectedItemImpl({
    required this.index,
    required this.category,
    this.subcategory,
    @JsonKey(name: 'color_hex') required this.colorHex,
    @JsonKey(name: 'color_name') required this.colorName,
    @JsonKey(name: 'color_hsl') required final Map<String, int> colorHsl,
    final List<String> style = const [],
    this.fit,
    this.pattern,
    this.isSelected = true,
  }) : _colorHsl = colorHsl,
       _style = style;

  factory _$DetectedItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$DetectedItemImplFromJson(json);

  @override
  final int index;
  @override
  final String category;
  @override
  final String? subcategory;
  @override
  @JsonKey(name: 'color_hex')
  final String colorHex;
  @override
  @JsonKey(name: 'color_name')
  final String colorName;
  final Map<String, int> _colorHsl;
  @override
  @JsonKey(name: 'color_hsl')
  Map<String, int> get colorHsl {
    if (_colorHsl is EqualUnmodifiableMapView) return _colorHsl;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_colorHsl);
  }

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
  @JsonKey()
  final bool isSelected;

  @override
  String toString() {
    return 'DetectedItem(index: $index, category: $category, subcategory: $subcategory, colorHex: $colorHex, colorName: $colorName, colorHsl: $colorHsl, style: $style, fit: $fit, pattern: $pattern, isSelected: $isSelected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetectedItemImpl &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.subcategory, subcategory) ||
                other.subcategory == subcategory) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.colorName, colorName) ||
                other.colorName == colorName) &&
            const DeepCollectionEquality().equals(other._colorHsl, _colorHsl) &&
            const DeepCollectionEquality().equals(other._style, _style) &&
            (identical(other.fit, fit) || other.fit == fit) &&
            (identical(other.pattern, pattern) || other.pattern == pattern) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    index,
    category,
    subcategory,
    colorHex,
    colorName,
    const DeepCollectionEquality().hash(_colorHsl),
    const DeepCollectionEquality().hash(_style),
    fit,
    pattern,
    isSelected,
  );

  /// Create a copy of DetectedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DetectedItemImplCopyWith<_$DetectedItemImpl> get copyWith =>
      __$$DetectedItemImplCopyWithImpl<_$DetectedItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DetectedItemImplToJson(this);
  }
}

abstract class _DetectedItem implements DetectedItem {
  const factory _DetectedItem({
    required final int index,
    required final String category,
    final String? subcategory,
    @JsonKey(name: 'color_hex') required final String colorHex,
    @JsonKey(name: 'color_name') required final String colorName,
    @JsonKey(name: 'color_hsl') required final Map<String, int> colorHsl,
    final List<String> style,
    final String? fit,
    final String? pattern,
    final bool isSelected,
  }) = _$DetectedItemImpl;

  factory _DetectedItem.fromJson(Map<String, dynamic> json) =
      _$DetectedItemImpl.fromJson;

  @override
  int get index;
  @override
  String get category;
  @override
  String? get subcategory;
  @override
  @JsonKey(name: 'color_hex')
  String get colorHex;
  @override
  @JsonKey(name: 'color_name')
  String get colorName;
  @override
  @JsonKey(name: 'color_hsl')
  Map<String, int> get colorHsl;
  @override
  List<String> get style;
  @override
  String? get fit;
  @override
  String? get pattern;
  @override
  bool get isSelected;

  /// Create a copy of DetectedItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DetectedItemImplCopyWith<_$DetectedItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
