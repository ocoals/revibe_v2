import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/categories.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/models/wardrobe_item.dart';
import '../data/wardrobe_repository.dart';

/// Repository singleton
final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  return WardrobeRepository();
});

/// Category filter state (null = all)
final wardrobeCategoryFilterProvider = StateProvider<ItemCategory?>((ref) {
  return null;
});

/// Wardrobe items list (reacts to category filter)
final wardrobeItemsProvider = FutureProvider<List<WardrobeItem>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repo = ref.watch(wardrobeRepositoryProvider);
  final filter = ref.watch(wardrobeCategoryFilterProvider);

  return repo.fetchItems(
    user.id,
    category: filter?.dbValue,
  );
});

/// Single item by ID
final wardrobeItemProvider =
    FutureProvider.family<WardrobeItem, String>((ref, id) async {
  final repo = ref.watch(wardrobeRepositoryProvider);
  return repo.fetchItem(id);
});

/// Active item count for free tier bar
final wardrobeCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;

  final repo = ref.watch(wardrobeRepositoryProvider);
  return repo.getItemCount(user.id);
});

/// Whether user can add more items (under free tier limit)
final canAddItemProvider = FutureProvider<bool>((ref) async {
  final count = await ref.watch(wardrobeCountProvider.future);
  return count < AppConfig.freeWardrobeLimit;
});
