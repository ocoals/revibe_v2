/// Subscription plan types offered in ClosetIQ.
enum SubscriptionPlan {
  monthly,
  yearly;

  String get displayName {
    return switch (this) {
      monthly => '월간 플랜',
      yearly => '연간 플랜',
    };
  }
}

/// User subscription status derived from RevenueCat CustomerInfo.
class SubscriptionInfo {
  final bool isPremium;
  final SubscriptionPlan? plan;
  final DateTime? expiresAt;
  final bool isInGracePeriod;

  const SubscriptionInfo({
    required this.isPremium,
    this.plan,
    this.expiresAt,
    this.isInGracePeriod = false,
  });

  /// Default free user status.
  static const free = SubscriptionInfo(isPremium: false);
}
