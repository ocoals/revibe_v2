import 'dart:async';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/config/revenuecat_config.dart';
import 'models/subscription_status.dart';

class SubscriptionService {
  StreamController<SubscriptionInfo>? _controller;

  /// Get current subscription info from RevenueCat.
  Future<SubscriptionInfo> getSubscriptionInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _parseCustomerInfo(customerInfo);
    } catch (_) {
      return SubscriptionInfo.free;
    }
  }

  /// Stream of subscription changes (listen for real-time updates).
  Stream<SubscriptionInfo> get subscriptionStream {
    _controller ??= StreamController<SubscriptionInfo>.broadcast(
      onListen: () {
        Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdate);
      },
      onCancel: () {
        Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdate);
      },
    );
    return _controller!.stream;
  }

  void _onCustomerInfoUpdate(CustomerInfo info) {
    _controller?.add(_parseCustomerInfo(info));
  }

  /// Fetch available offerings (products + prices).
  Future<Offerings> getOfferings() async {
    return Purchases.getOfferings();
  }

  /// Purchase a package (triggers native payment sheet).
  Future<SubscriptionInfo> purchase(Package package) async {
    final customerInfo = await Purchases.purchasePackage(package);
    return _parseCustomerInfo(customerInfo);
  }

  /// Restore previous purchases (required by Apple).
  Future<SubscriptionInfo> restorePurchases() async {
    final customerInfo = await Purchases.restorePurchases();
    return _parseCustomerInfo(customerInfo);
  }

  /// Parse RevenueCat CustomerInfo into our model.
  SubscriptionInfo _parseCustomerInfo(CustomerInfo info) {
    final entitlement =
        info.entitlements.active[RevenueCatConfig.entitlementId];
    if (entitlement == null) return SubscriptionInfo.free;

    final productId = entitlement.productIdentifier;
    final plan = productId.contains('yearly')
        ? SubscriptionPlan.yearly
        : SubscriptionPlan.monthly;

    final expiresAt = entitlement.expirationDate != null
        ? DateTime.parse(entitlement.expirationDate!)
        : null;

    // Grace period detection: billingIssueDetectedAt is non-null during grace period
    final isGrace = info.entitlements.all[RevenueCatConfig.entitlementId]
            ?.billingIssueDetectedAt !=
        null;

    return SubscriptionInfo(
      isPremium: true,
      plan: plan,
      expiresAt: expiresAt,
      isInGracePeriod: isGrace,
    );
  }
}
