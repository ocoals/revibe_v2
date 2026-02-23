import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class BackgroundRemovalResult {
  final Uint8List imageBytes;
  final bool usedFallback;

  const BackgroundRemovalResult({
    required this.imageBytes,
    required this.usedFallback,
  });
}

class BackgroundRemovalService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Remove background from image via Edge Function.
  /// Returns processed image bytes, or original on failure.
  Future<BackgroundRemovalResult> removeBackground(
    Uint8List imageBytes,
  ) async {
    try {
      final response = await _client.functions.invoke(
        'remove-background',
        body: {
          'image_base64': base64Encode(imageBytes),
        },
      );

      if (response.status != 200) {
        debugPrint('Background removal failed: status=${response.status}');
        return BackgroundRemovalResult(
          imageBytes: imageBytes,
          usedFallback: true,
        );
      }

      final data = response.data as Map<String, dynamic>;
      final resultBase64 = data['image_base64'] as String;
      final usedFallback = data['used_fallback'] as bool? ?? false;

      return BackgroundRemovalResult(
        imageBytes: base64Decode(resultBase64),
        usedFallback: usedFallback,
      );
    } catch (e) {
      debugPrint('Background removal error: $e');
      return BackgroundRemovalResult(
        imageBytes: imageBytes,
        usedFallback: true,
      );
    }
  }
}

final backgroundRemovalServiceProvider = Provider<BackgroundRemovalService>(
  (ref) => BackgroundRemovalService(),
);
