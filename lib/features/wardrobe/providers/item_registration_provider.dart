import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/background_removal_service.dart';
import '../../../core/utils/color_utils.dart';
import '../../auth/providers/auth_provider.dart';
import 'wardrobe_provider.dart';

/// Temporary image bytes after camera/gallery capture
final pendingImageProvider = StateProvider<Uint8List?>((ref) => null);

/// Registration form state
class ItemRegistrationState {
  final String? category;
  final String? subcategory;
  final String? colorHex;
  final String? fit;
  final String? pattern;
  final String? brand;
  final List<String> season;
  final bool isSubmitting;
  final String? error;

  const ItemRegistrationState({
    this.category,
    this.subcategory,
    this.colorHex,
    this.fit,
    this.pattern,
    this.brand,
    this.season = const ['spring', 'summer', 'fall', 'winter'],
    this.isSubmitting = false,
    this.error,
  });

  ItemRegistrationState copyWith({
    String? category,
    String? subcategory,
    String? colorHex,
    String? fit,
    String? pattern,
    String? brand,
    List<String>? season,
    bool? isSubmitting,
    String? error,
    bool clearSubcategory = false,
    bool clearFit = false,
    bool clearPattern = false,
    bool clearError = false,
  }) {
    return ItemRegistrationState(
      category: category ?? this.category,
      subcategory: clearSubcategory ? null : (subcategory ?? this.subcategory),
      colorHex: colorHex ?? this.colorHex,
      fit: clearFit ? null : (fit ?? this.fit),
      pattern: clearPattern ? null : (pattern ?? this.pattern),
      brand: brand ?? this.brand,
      season: season ?? this.season,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Form state notifier
class ItemRegistrationNotifier extends StateNotifier<ItemRegistrationState> {
  ItemRegistrationNotifier(this._ref) : super(const ItemRegistrationState());

  final Ref _ref;

  void setCategory(String category) {
    state = state.copyWith(category: category, clearSubcategory: true);
  }

  void setSubcategory(String? subcategory) {
    state = state.copyWith(subcategory: subcategory);
  }

  void setColorHex(String hex) {
    state = state.copyWith(colorHex: hex);
  }

  void setFit(String? fit) {
    if (state.fit == fit) {
      state = state.copyWith(clearFit: true);
    } else {
      state = state.copyWith(fit: fit);
    }
  }

  void setPattern(String? pattern) {
    if (state.pattern == pattern) {
      state = state.copyWith(clearPattern: true);
    } else {
      state = state.copyWith(pattern: pattern);
    }
  }

  void setBrand(String brand) {
    state = state.copyWith(brand: brand.isEmpty ? null : brand);
  }

  void toggleSeason(String season) {
    final current = List<String>.from(state.season);
    if (current.contains(season)) {
      current.remove(season);
    } else {
      current.add(season);
    }
    state = state.copyWith(season: current);
  }

  /// Submit: upload image → build data → insert to DB
  Future<bool> submit() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return false;

    final imageBytes = _ref.read(pendingImageProvider);
    if (imageBytes == null) return false;

    if (state.category == null || state.colorHex == null) {
      state = state.copyWith(error: '카테고리와 색상은 필수입니다');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final repo = _ref.read(wardrobeRepositoryProvider);
      final bgService = _ref.read(backgroundRemovalServiceProvider);

      // Remove background, then upload
      final bgResult = await bgService.removeBackground(imageBytes);
      final String imageUrl;
      if (bgResult.usedFallback) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await repo.uploadImage(user.id, bgResult.imageBytes, fileName);
      } else {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_processed.png';
        imageUrl = await repo.uploadProcessedImage(
          user.id, bgResult.imageBytes, fileName,
        );
      }

      // Get Korean color name from hex
      final colorName = ColorUtils.hexToKoreanName(state.colorHex!);
      final colorHsl = ColorUtils.hexToHsl(state.colorHex!);

      // Build insert data
      final data = <String, dynamic>{
        'user_id': user.id,
        'image_url': imageUrl,
        'category': state.category,
        'subcategory': state.subcategory,
        'color_hex': state.colorHex,
        'color_name': colorName,
        'color_hsl': colorHsl.toJson(),
        'fit': state.fit,
        'pattern': state.pattern,
        'brand': state.brand,
        'season': state.season,
      };

      await repo.createItem(data);

      // Invalidate wardrobe providers to refresh lists
      _ref.invalidate(wardrobeItemsProvider);
      _ref.invalidate(wardrobeCountProvider);
      _ref.invalidate(canAddItemProvider);

      // Clear pending image
      _ref.read(pendingImageProvider.notifier).state = null;

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: '등록에 실패했습니다. 다시 시도해주세요.',
      );
      return false;
    }
  }
}

final itemRegistrationProvider =
    StateNotifierProvider.autoDispose<ItemRegistrationNotifier, ItemRegistrationState>(
  (ref) => ItemRegistrationNotifier(ref),
);
