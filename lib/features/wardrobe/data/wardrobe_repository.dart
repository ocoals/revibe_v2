import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import 'models/wardrobe_item.dart';

class WardrobeRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  static const _table = 'wardrobe_items';
  static const _bucket = 'wardrobe-images';

  /// Fetch active wardrobe items, optionally filtered by category
  Future<List<WardrobeItem>> fetchItems(
    String userId, {
    String? category,
  }) async {
    var query = _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('is_active', true);

    if (category != null) {
      query = query.eq('category', category);
    }

    final data = await query.order('created_at', ascending: false);
    return data.map((json) => WardrobeItem.fromJson(json)).toList();
  }

  /// Fetch a single item by ID
  Future<WardrobeItem> fetchItem(String id) async {
    final data = await _client.from(_table).select().eq('id', id).single();
    return WardrobeItem.fromJson(data);
  }

  /// Upload image to Storage and return public URL
  Future<String> uploadImage(
    String userId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    final path = '$userId/$fileName';
    await _client.storage.from(_bucket).uploadBinary(
          path,
          imageBytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );
    return _client.storage.from(_bucket).getPublicUrl(path);
  }

  /// Upload processed (background-removed) image as PNG
  Future<String> uploadProcessedImage(
    String userId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    final path = '$userId/$fileName';
    await _client.storage.from(_bucket).uploadBinary(
          path,
          imageBytes,
          fileOptions: const FileOptions(
            contentType: 'image/png',
            upsert: true,
          ),
        );
    return _client.storage.from(_bucket).getPublicUrl(path);
  }

  /// Insert a new wardrobe item
  Future<WardrobeItem> createItem(Map<String, dynamic> data) async {
    final result = await _client.from(_table).insert(data).select().single();
    return WardrobeItem.fromJson(result);
  }

  /// Soft delete (set is_active = false)
  Future<void> deleteItem(String id) async {
    await _client.from(_table).update({'is_active': false}).eq('id', id);
  }

  /// Get count of active items for free tier limit check
  Future<int> getItemCount(String userId) async {
    final result = await _client
        .from(_table)
        .select('id')
        .eq('user_id', userId)
        .eq('is_active', true);
    return (result as List).length;
  }
}
