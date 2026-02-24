import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatConfig {
  /// RevenueCat API keys (set via --dart-define)
  static const String _appleApiKey = String.fromEnvironment(
    'REVENUECAT_APPLE_KEY',
    defaultValue: '',
  );
  static const String _googleApiKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_KEY',
    defaultValue: '',
  );

  /// Entitlement identifier configured in RevenueCat dashboard
  static const String entitlementId = 'premium';

  /// Whether RevenueCat was successfully configured
  static bool isConfigured = false;

  /// Initialize RevenueCat SDK. Call once at app startup.
  static Future<void> initialize({String? userId}) async {
    final apiKey = Platform.isIOS ? _appleApiKey : _googleApiKey;
    if (apiKey.isEmpty) return; // Skip in dev/test without keys

    final config = PurchasesConfiguration(apiKey);
    if (userId != null) {
      config.appUserID = userId;
    }
    await Purchases.configure(config);
    isConfigured = true;
  }

  /// Log in user to RevenueCat (call after Supabase auth)
  static Future<void> login(String userId) async {
    if (!isConfigured) return;
    try {
      await Purchases.logIn(userId);
    } catch (_) {
      // Non-critical: SDK works with anonymous ID
    }
  }

  /// Log out from RevenueCat (call on sign out)
  static Future<void> logout() async {
    if (!isConfigured) return;
    try {
      await Purchases.logOut();
    } catch (_) {
      // Ignore
    }
  }
}
