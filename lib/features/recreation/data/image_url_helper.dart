import '../../../core/config/supabase_config.dart';

/// Resolve a reference image URL or storage path to a full accessible URL.
/// Handles both legacy full URLs (containing kong:8000) and new path-only values.
String resolveReferenceImageUrl(String urlOrPath) {
  // Already a valid external URL
  if (urlOrPath.startsWith('http') && !urlOrPath.contains('kong:')) {
    return urlOrPath;
  }

  // Extract path from internal Docker URL if needed
  String path = urlOrPath;
  if (urlOrPath.contains('kong:')) {
    final idx = urlOrPath.indexOf('reference-images/');
    if (idx != -1) {
      path = urlOrPath.substring(idx + 'reference-images/'.length);
    }
  }

  // Build public storage URL (bucket is public)
  return '${SupabaseConfig.url}/storage/v1/object/public/reference-images/$path';
}
