class AppConfig {
  static const String appName = 'RE:VIBE';
  static const String appVersion = '1.0.0';

  // Free tier limits
  static const int freeWardrobeLimit = 30;
  static const int freeRecreationMonthlyLimit = 5;

  // Image processing
  static const int maxImageSizeMB = 10;
  static const int maxImageDimensionPx = 2048;
  static const int jpegQuality = 85;

  // API timeouts
  static const Duration apiTimeout = Duration(seconds: 10);
  static const Duration imageUploadTimeout = Duration(seconds: 30);

  // Legal URLs (GitHub Pages에 배포 후 실제 URL로 교체)
  static const String privacyPolicyUrl = 'https://ocoals.github.io/revibe_v2/privacy.html';
  static const String termsOfServiceUrl = 'https://ocoals.github.io/revibe_v2/terms.html';
}
