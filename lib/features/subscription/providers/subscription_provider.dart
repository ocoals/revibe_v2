import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../data/models/subscription_status.dart';
import '../data/subscription_service.dart';

/// Subscription service singleton.
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

/// Current subscription info (auto-updates via stream).
final subscriptionProvider =
    StreamProvider<SubscriptionInfo>((ref) async* {
  final service = ref.watch(subscriptionServiceProvider);

  // Emit current state first
  yield await service.getSubscriptionInfo();

  // Then listen to changes
  yield* service.subscriptionStream;
});

/// Simple boolean: is user premium?
final isPremiumProvider = Provider<bool>((ref) {
  final sub = ref.watch(subscriptionProvider).valueOrNull;
  return sub?.isPremium ?? false;
});

/// Available offerings for Paywall.
final offeringsProvider = FutureProvider<Offerings>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getOfferings();
});
