import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import 'models/look_recreation.dart';

class RecreationRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  static const _table = 'look_recreations';
  static const _usageTable = 'usage_counters';

  /// Call recreate-analyze Edge Function
  /// Sends reference image as base64, returns LookRecreation result
  Future<LookRecreation> analyze(Uint8List imageBytes) async {
    final response = await _client.functions.invoke(
      'recreate-analyze',
      body: {
        'image_base64': base64Encode(imageBytes),
      },
    );

    if (response.status != 200) {
      final error = response.data as Map<String, dynamic>?;
      throw RecreationException(
        code: error?['code'] as String? ?? 'UNKNOWN_ERROR',
        message: error?['error'] as String? ?? 'Unknown error',
        statusCode: response.status,
      );
    }

    return LookRecreation.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetch recreation history (paginated)
  Future<List<LookRecreation>> fetchHistory({
    int limit = 10,
    int offset = 0,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('status', 'completed')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return data.map((json) => LookRecreation.fromJson(json)).toList();
  }

  /// Fetch single recreation by ID
  Future<LookRecreation> fetchById(String id) async {
    final data = await _client.from(_table).select().eq('id', id).single();
    return LookRecreation.fromJson(data);
  }

  /// Get current month recreation count
  Future<int> getMonthlyUsage() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final monthKey = _currentMonthKey();
    final result = await _client
        .from(_usageTable)
        .select('recreation_count')
        .eq('user_id', userId)
        .eq('month_key', monthKey)
        .maybeSingle();

    return (result?['recreation_count'] as int?) ?? 0;
  }

  String _currentMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }
}

/// Custom exception for recreation errors
class RecreationException implements Exception {
  final String code;
  final String message;
  final int statusCode;

  const RecreationException({
    required this.code,
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'RecreationException($code): $message';
}
