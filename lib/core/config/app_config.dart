class AppConfig {
  static const String appName = 'ClosetIQ';
  static const String appVersion = '0.1.0';

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
}
