// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wardrobe_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WardrobeItem _$WardrobeItemFromJson(Map<String, dynamic> json) {
  return _WardrobeItem.fromJson(json);
}

/// @nodoc
mixin _$WardrobeItem {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_image_url')
  String? get originalImageUrl => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get subcategory => throw _privateConstructorUsedError;
  @JsonKey(name: 'color_hex')
  String get colorHex => throw _privateConstructorUsedError;
  @JsonKey(name: 'color_name')
  String get colorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'color_hsl')
  Map<String, int> get colorHsl => throw _privateConstructorUsedError;
  @JsonKey(name: 'style_tags')
  List<String> get styleTags => throw _privateConstructorUsedError;
  String? get fit => throw _privateConstructorUsedError;
  String? get pattern => throw _privateConstructorUsedError;
  String? get brand => throw _privateConstructorUsedError;
  List<String> get season => throw _privateConstructorUsedError;
  @JsonKey(name: 'wear_count')
  int get wearCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_worn_at')
  DateTime? get lastWornAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WardrobeItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WardrobeItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WardrobeItemCopyWith<WardrobeItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WardrobeItemCopyWith<$Res> {
  factory $WardrobeItemCopyWith(
    WardrobeItem value,
    $Res Function(WardrobeItem) then,
  ) = _$WardrobeItemCopyWithImpl<$Res, WardrobeItem>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'image_url') String imageUrl,
    @JsonKey(name: 'original_image_url') String? originalImageUrl,
    String category,
    String? subcategory,
    @JsonKey(name: 'color_hex') String colorHex,
    @JsonKey(name: 'color_name') String colorName,
    @JsonKey(name: 'color_hsl') Map<String, int> colorHsl,
    @JsonKey(name: 'style_tags') List<String> styleTags,
    String? fit,
    String? pattern,
    String? brand,
    List<String> season,
    @JsonKey(name: 'wear_count') int wearCount,
    @JsonKey(name: 'last_worn_at') DateTime? lastWornAt,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$WardrobeItemCopyWithImpl<$Res, $Val extends WardrobeItem>
    implements $WardrobeItemCopyWith<$Res> {
  _$WardrobeItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WardrobeItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? imageUrl = null,
    Object? originalImageUrl = freezed,
    Object? category = null,
    Object? subcategory = freezed,
    Object? colorHex = null,
    Object? colorName = null,
    Object? colorHsl = null,
    Object? styleTags = null,
    Object? fit = freezed,
    Object? pattern = freezed,
    Object? brand = freezed,
    Object? season = null,
    Object? wearCount = null,
    Object? lastWornAt = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            originalImageUrl: freezed == originalImageUrl
                ? _value.originalImageUrl
                : originalImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            styleTags: null == styleTags
                ? _value.styleTags
                : styleTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            fit: freezed == fit
                ? _value.fit
                : fit // ignore: cast_nullable_to_non_nullable
                      as String?,
            pattern: freezed == pattern
                ? _value.pattern
                : pattern // ignore: cast_nullable_to_non_nullable
                      as String?,
            brand: freezed == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
                      as String?,
            season: null == season
                ? _value.season
                : season // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            wearCount: null == wearCount
                ? _value.wearCount
                : wearCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastWornAt: freezed == lastWornAt
                ? _value.lastWornAt
                : lastWornAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WardrobeItemImplCopyWith<$Res>
    implements $WardrobeItemCopyWith<$Res> {
  factory _$$WardrobeItemImplCopyWith(
    _$WardrobeItemImpl value,
    $Res Function(_$WardrobeItemImpl) then,
  ) = __$$WardrobeItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'image_url') String imageUrl,
    @JsonKey(name: 'original_image_url') String? originalImageUrl,
    String category,
    String? subcategory,
    @JsonKey(name: 'color_hex') String colorHex,
    @JsonKey(name: 'color_name') String colorName,
    @JsonKey(name: 'color_hsl') Map<String, int> colorHsl,
    @JsonKey(name: 'style_tags') List<String> styleTags,
    String? fit,
    String? pattern,
    String? brand,
    List<String> season,
    @JsonKey(name: 'wear_count') int wearCount,
    @JsonKey(name: 'last_worn_at') DateTime? lastWornAt,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$WardrobeItemImplCopyWithImpl<$Res>
    extends _$WardrobeItemCopyWithImpl<$Res, _$WardrobeItemImpl>
    implements _$$WardrobeItemImplCopyWith<$Res> {
  __$$WardrobeItemImplCopyWithImpl(
    _$WardrobeItemImpl _value,
    $Res Function(_$WardrobeItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WardrobeItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? imageUrl = null,
    Object? originalImageUrl = freezed,
    Object? category = null,
    Object? subcategory = freezed,
    Object? colorHex = null,
    Object? colorName = null,
    Object? colorHsl = null,
    Object? styleTags = null,
    Object? fit = freezed,
    Object? pattern = freezed,
    Object? brand = freezed,
    Object? season = null,
    Object? wearCount = null,
    Object? lastWornAt = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$WardrobeItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        originalImageUrl: freezed == originalImageUrl
            ? _value.originalImageUrl
            : originalImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        styleTags: null == styleTags
            ? _value._styleTags
            : styleTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        fit: freezed == fit
            ? _value.fit
            : fit // ignore: cast_nullable_to_non_nullable
                  as String?,
        pattern: freezed == pattern
            ? _value.pattern
            : pattern // ignore: cast_nullable_to_non_nullable
                  as String?,
        brand: freezed == brand
            ? _value.brand
            : brand // ignore: cast_nullable_to_non_nullable
                  as String?,
        season: null == season
            ? _value._season
            : season // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        wearCount: null == wearCount
            ? _value.wearCount
            : wearCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastWornAt: freezed == lastWornAt
            ? _value.lastWornAt
            : lastWornAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WardrobeItemImpl implements _WardrobeItem {
  const _$WardrobeItemImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'image_url') required this.imageUrl,
    @JsonKey(name: 'original_image_url') this.originalImageUrl,
    required this.category,
    this.subcategory,
    @JsonKey(name: 'color_hex') required this.colorHex,
    @JsonKey(name: 'color_name') required this.colorName,
    @JsonKey(name: 'color_hsl') required final Map<String, int> colorHsl,
    @JsonKey(name: 'style_tags') final List<String> styleTags = const [],
    this.fit,
    this.pattern,
    this.brand,
    final List<String> season = const ['spring', 'summer', 'fall', 'winter'],
    @JsonKey(name: 'wear_count') this.wearCount = 0,
    @JsonKey(name: 'last_worn_at') this.lastWornAt,
    @JsonKey(name: 'is_active') this.isActive = true,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  }) : _colorHsl = colorHsl,
       _styleTags = styleTags,
       _season = season;

  factory _$WardrobeItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$WardrobeItemImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @override
  @JsonKey(name: 'original_image_url')
  final String? originalImageUrl;
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

  final List<String> _styleTags;
  @override
  @JsonKey(name: 'style_tags')
  List<String> get styleTags {
    if (_styleTags is EqualUnmodifiableListView) return _styleTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_styleTags);
  }

  @override
  final String? fit;
  @override
  final String? pattern;
  @override
  final String? brand;
  final List<String> _season;
  @override
  @JsonKey()
  List<String> get season {
    if (_season is EqualUnmodifiableListView) return _season;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_season);
  }

  @override
  @JsonKey(name: 'wear_count')
  final int wearCount;
  @override
  @JsonKey(name: 'last_worn_at')
  final DateTime? lastWornAt;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'WardrobeItem(id: $id, userId: $userId, imageUrl: $imageUrl, originalImageUrl: $originalImageUrl, category: $category, subcategory: $subcategory, colorHex: $colorHex, colorName: $colorName, colorHsl: $colorHsl, styleTags: $styleTags, fit: $fit, pattern: $pattern, brand: $brand, season: $season, wearCount: $wearCount, lastWornAt: $lastWornAt, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WardrobeItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.originalImageUrl, originalImageUrl) ||
                other.originalImageUrl == originalImageUrl) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.subcategory, subcategory) ||
                other.subcategory == subcategory) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.colorName, colorName) ||
                other.colorName == colorName) &&
            const DeepCollectionEquality().equals(other._colorHsl, _colorHsl) &&
            const DeepCollectionEquality().equals(
              other._styleTags,
              _styleTags,
            ) &&
            (identical(other.fit, fit) || other.fit == fit) &&
            (identical(other.pattern, pattern) || other.pattern == pattern) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            const DeepCollectionEquality().equals(other._season, _season) &&
            (identical(other.wearCount, wearCount) ||
                other.wearCount == wearCount) &&
            (identical(other.lastWornAt, lastWornAt) ||
                other.lastWornAt == lastWornAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    userId,
    imageUrl,
    originalImageUrl,
    category,
    subcategory,
    colorHex,
    colorName,
    const DeepCollectionEquality().hash(_colorHsl),
    const DeepCollectionEquality().hash(_styleTags),
    fit,
    pattern,
    brand,
    const DeepCollectionEquality().hash(_season),
    wearCount,
    lastWornAt,
    isActive,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of WardrobeItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WardrobeItemImplCopyWith<_$WardrobeItemImpl> get copyWith =>
      __$$WardrobeItemImplCopyWithImpl<_$WardrobeItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WardrobeItemImplToJson(this);
  }
}

abstract class _WardrobeItem implements WardrobeItem {
  const factory _WardrobeItem({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'image_url') required final String imageUrl,
    @JsonKey(name: 'original_image_url') final String? originalImageUrl,
    required final String category,
    final String? subcategory,
    @JsonKey(name: 'color_hex') required final String colorHex,
    @JsonKey(name: 'color_name') required final String colorName,
    @JsonKey(name: 'color_hsl') required final Map<String, int> colorHsl,
    @JsonKey(name: 'style_tags') final List<String> styleTags,
    final String? fit,
    final String? pattern,
    final String? brand,
    final List<String> season,
    @JsonKey(name: 'wear_count') final int wearCount,
    @JsonKey(name: 'last_worn_at') final DateTime? lastWornAt,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$WardrobeItemImpl;

  factory _WardrobeItem.fromJson(Map<String, dynamic> json) =
      _$WardrobeItemImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;
  @override
  @JsonKey(name: 'original_image_url')
  String? get originalImageUrl;
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
  @JsonKey(name: 'style_tags')
  List<String> get styleTags;
  @override
  String? get fit;
  @override
  String? get pattern;
  @override
  String? get brand;
  @override
  List<String> get season;
  @override
  @JsonKey(name: 'wear_count')
  int get wearCount;
  @override
  @JsonKey(name: 'last_worn_at')
  DateTime? get lastWornAt;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of WardrobeItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WardrobeItemImplCopyWith<_$WardrobeItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
