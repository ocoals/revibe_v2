import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../wardrobe/data/models/wardrobe_item.dart';
import 'models/daily_outfit.dart';

class DailyRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  static const _outfitTable = 'daily_outfits';
  static const _itemsTable = 'outfit_items';
  static const _wardrobeTable = 'wardrobe_items';

  /// Save a daily outfit record with selected items.
  /// Uses upsert on (user_id, outfit_date) to allow editing same day.
  /// Also increments wear_count and updates last_worn_at for each item.
  Future<DailyOutfit> saveOutfit({
    required DateTime date,
    required List<String> itemIds,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('User not authenticated');
    final dateStr = _formatDate(date);

    // 1. Upsert daily_outfits record
    final outfitData = await _client
        .from(_outfitTable)
        .upsert(
          {
            'user_id': userId,
            'outfit_date': dateStr,
            'notes': notes,
          },
          onConflict: 'user_id,outfit_date',
        )
        .select()
        .single();

    final outfitId = outfitData['id'] as String;

    // 2. Delete existing outfit_items for this outfit (replace all)
    await _client.from(_itemsTable).delete().eq('outfit_id', outfitId);

    // 3. Insert new outfit_items
    if (itemIds.isNotEmpty) {
      final itemRows = itemIds.asMap().entries.map((e) => {
            'outfit_id': outfitId,
            'item_id': e.value,
            'position': e.key,
          }).toList();
      await _client.from(_itemsTable).insert(itemRows);
    }

    // 4. Update wardrobe_items: wear_count +1, last_worn_at = outfit_date
    for (final itemId in itemIds) {
      await _client.rpc('increment_wear_count', params: {
        'p_item_id': itemId,
        'p_worn_date': dateStr,
      });
    }

    return DailyOutfit.fromJson(outfitData);
  }

  /// Fetch all daily outfits for a given month (for calendar view).
  Future<List<DailyOutfit>> fetchMonthOutfits({
    required int year,
    required int month,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final endDate = month == 12
        ? '${year + 1}-01-01'
        : '$year-${(month + 1).toString().padLeft(2, '0')}-01';

    final data = await _client
        .from(_outfitTable)
        .select()
        .eq('user_id', userId)
        .gte('outfit_date', startDate)
        .lt('outfit_date', endDate)
        .order('outfit_date', ascending: true);

    return data.map((json) => DailyOutfit.fromJson(json)).toList();
  }

  /// Fetch a single outfit with its wardrobe items (for detail view).
  Future<DailyOutfitDetail?> fetchOutfitWithItems({
    required DateTime date,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final dateStr = _formatDate(date);

    // Fetch outfit
    final outfitData = await _client
        .from(_outfitTable)
        .select()
        .eq('user_id', userId)
        .eq('outfit_date', dateStr)
        .maybeSingle();

    if (outfitData == null) return null;

    final outfit = DailyOutfit.fromJson(outfitData);

    // Fetch joined items via outfit_items -> wardrobe_items
    final itemsData = await _client
        .from(_itemsTable)
        .select('position, $_wardrobeTable(*)')
        .eq('outfit_id', outfit.id)
        .order('position', ascending: true);

    final items = itemsData
        .map((row) =>
            WardrobeItem.fromJson(row[_wardrobeTable] as Map<String, dynamic>))
        .toList();

    return DailyOutfitDetail(outfit: outfit, items: items);
  }

  /// Fetch recent N days of outfits with their items in batch (2 queries).
  Future<List<DailyOutfitDetail>> fetchRecentOutfitsWithItems({
    int days = 7,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final now = DateTime.now();
    final startDate = _formatDate(now.subtract(Duration(days: days)));

    // Query 1: Fetch all outfits in date range
    final outfitsData = await _client
        .from(_outfitTable)
        .select()
        .eq('user_id', userId)
        .gte('outfit_date', startDate)
        .order('outfit_date', ascending: false);

    if (outfitsData.isEmpty) return [];

    final outfits =
        outfitsData.map((json) => DailyOutfit.fromJson(json)).toList();
    final outfitIds = outfits.map((o) => o.id).toList();

    // Query 2: Fetch all outfit_items with joined wardrobe_items
    final itemsData = await _client
        .from(_itemsTable)
        .select('outfit_id, position, $_wardrobeTable(*)')
        .inFilter('outfit_id', outfitIds)
        .order('position', ascending: true);

    // Group items by outfit_id
    final itemsByOutfit = <String, List<WardrobeItem>>{};
    for (final row in itemsData) {
      final outfitId = row['outfit_id'] as String;
      final item = WardrobeItem.fromJson(
          row[_wardrobeTable] as Map<String, dynamic>);
      itemsByOutfit.putIfAbsent(outfitId, () => []).add(item);
    }

    return outfits
        .map((outfit) => DailyOutfitDetail(
              outfit: outfit,
              items: itemsByOutfit[outfit.id] ?? [],
            ))
        .toList();
  }

  /// Delete a daily outfit record.
  Future<void> deleteOutfit(String outfitId) async {
    await _client.from(_outfitTable).delete().eq('id', outfitId);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Outfit with joined wardrobe items for detail view
class DailyOutfitDetail {
  final DailyOutfit outfit;
  final List<WardrobeItem> items;

  const DailyOutfitDetail({required this.outfit, required this.items});
}
