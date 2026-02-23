import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import 'models/detected_item.dart';

class OnboardingRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Call onboarding-analyze Edge Function
  /// Sends image as base64, returns detected items list
  Future<List<DetectedItem>> analyzeOutfit(Uint8List imageBytes) async {
    final response = await _client.functions.invoke(
      'onboarding-analyze',
      body: {
        'image_base64': base64Encode(imageBytes),
      },
    );

    if (response.status != 200) {
      final error = response.data as Map<String, dynamic>?;
      throw OnboardingAnalysisException(
        code: error?['code'] as String? ?? 'UNKNOWN_ERROR',
        message: error?['error'] as String? ?? 'Unknown error',
        statusCode: response.status,
      );
    }

    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];

    return items
        .map((item) =>
            DetectedItem.fromAnalysisJson(item as Map<String, dynamic>))
        .toList();
  }
}

class OnboardingAnalysisException implements Exception {
  final String code;
  final String message;
  final int statusCode;

  const OnboardingAnalysisException({
    required this.code,
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'OnboardingAnalysisException($code): $message';
}
