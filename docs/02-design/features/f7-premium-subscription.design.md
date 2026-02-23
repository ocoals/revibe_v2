# F7 프리미엄 구독 시스템 — 설계서

> **Feature:** f7-premium-subscription
> **Phase:** Design
> **Created:** 2026-02-23
> **Status:** Draft
> **Plan Ref:** [f7-premium-subscription.plan.md](../../01-plan/features/f7-premium-subscription.plan.md)

---

## 1. 아키텍처 개요

```
┌─────────────────────────────────────────────────┐
│  Presentation Layer                              │
│  ├── PaywallScreen (S18)                         │
│  ├── SubscriptionManageScreen (S19)              │
│  └── LimitReachedSheet (widget)                  │
├─────────────────────────────────────────────────┤
│  Provider Layer                                  │
│  ├── subscriptionProvider (CustomerInfo stream)  │
│  ├── isPremiumProvider (bool)                    │
│  └── offeringsProvider (Offerings)               │
├─────────────────────────────────────────────────┤
│  Service Layer                                   │
│  └── SubscriptionService (RevenueCat SDK wrapper)│
├─────────────────────────────────────────────────┤
│  Config Layer                                    │
│  └── RevenueCatConfig (API key, init)            │
├─────────────────────────────────────────────────┤
│  External                                        │
│  ├── RevenueCat SDK ↔ Apple IAP / Google Billing │
│  └── Supabase profiles (backup sync)             │
└─────────────────────────────────────────────────┘
```

## 2. 데이터 모델

### 2.1 SubscriptionStatus (Plain Dart Enum)

**파일:** `lib/features/subscription/data/models/subscription_status.dart`

```dart
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
```

### 2.2 DB 마이그레이션

**파일:** `supabase/migrations/20260224000001_add_subscription_columns.sql`

```sql
-- Add subscription tracking columns to profiles
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS subscription_status TEXT
    CHECK (subscription_status IN ('free','active','expired','grace_period'))
    DEFAULT 'free',
  ADD COLUMN IF NOT EXISTS subscription_plan TEXT
    CHECK (subscription_plan IN ('monthly','yearly'))
    DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS subscription_expires_at TIMESTAMPTZ DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS revenuecat_id TEXT DEFAULT NULL;
```

## 3. RevenueCat 설정

### 3.1 RevenueCatConfig

**파일:** `lib/core/config/revenuecat_config.dart`

```dart
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

  /// Initialize RevenueCat SDK. Call once at app startup.
  static Future<void> initialize({String? userId}) async {
    final apiKey = Platform.isIOS ? _appleApiKey : _googleApiKey;
    if (apiKey.isEmpty) return; // Skip in dev/test without keys

    final config = PurchasesConfiguration(apiKey);
    if (userId != null) {
      config.appUserID = userId;
    }
    await Purchases.configure(config);
  }

  /// Log in user to RevenueCat (call after Supabase auth)
  static Future<void> login(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (_) {
      // Non-critical: SDK works with anonymous ID
    }
  }

  /// Log out from RevenueCat (call on sign out)
  static Future<void> logout() async {
    try {
      await Purchases.logOut();
    } catch (_) {
      // Ignore
    }
  }
}
```

### 3.2 main.dart 수정

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  await RevenueCatConfig.initialize();  // 추가

  runApp(
    const ProviderScope(
      child: ClosetIQApp(),
    ),
  );
}
```

## 4. 서비스 레이어

### 4.1 SubscriptionService

**파일:** `lib/features/subscription/data/subscription_service.dart`

```dart
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/config/revenuecat_config.dart';
import 'models/subscription_status.dart';

class SubscriptionService {
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
    return Purchases.customerInfoStream.map(_parseCustomerInfo);
  }

  /// Fetch available offerings (products + prices).
  Future<Offerings> getOfferings() async {
    return Purchases.getOfferings();
  }

  /// Purchase a package (triggers native payment sheet).
  Future<SubscriptionInfo> purchase(Package package) async {
    final result = await Purchases.purchasePackage(package);
    return _parseCustomerInfo(result);
  }

  /// Restore previous purchases (required by Apple).
  Future<SubscriptionInfo> restorePurchases() async {
    final customerInfo = await Purchases.restorePurchases();
    return _parseCustomerInfo(customerInfo);
  }

  /// Parse RevenueCat CustomerInfo into our model.
  SubscriptionInfo _parseCustomerInfo(CustomerInfo info) {
    final entitlement = info.entitlements.active[RevenueCatConfig.entitlementId];
    if (entitlement == null) return SubscriptionInfo.free;

    final productId = entitlement.productIdentifier;
    final plan = productId.contains('yearly')
        ? SubscriptionPlan.yearly
        : SubscriptionPlan.monthly;

    final expiresAt = entitlement.expirationDate != null
        ? DateTime.parse(entitlement.expirationDate!)
        : null;

    final isGrace = entitlement.periodType == PeriodType.grace;

    return SubscriptionInfo(
      isPremium: true,
      plan: plan,
      expiresAt: expiresAt,
      isInGracePeriod: isGrace,
    );
  }
}
```

## 5. Provider 레이어

### 5.1 SubscriptionProvider

**파일:** `lib/features/subscription/providers/subscription_provider.dart`

```dart
import 'dart:async';
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
```

### 5.2 기존 Provider 수정

#### wardrobe_provider.dart — canAddItemProvider 수정

```dart
// 기존:
// final canAddItemProvider = FutureProvider<bool>((ref) async {
//   final count = await ref.watch(wardrobeCountProvider.future);
//   return count < AppConfig.freeWardrobeLimit;
// });

// 수정:
final canAddItemProvider = FutureProvider<bool>((ref) async {
  final isPremium = ref.watch(isPremiumProvider);
  if (isPremium) return true;

  final count = await ref.watch(wardrobeCountProvider.future);
  return count < AppConfig.freeWardrobeLimit;
});
```

**필요 import 추가:**
```dart
import '../../subscription/providers/subscription_provider.dart';
```

#### usage_provider.dart — canRecreateProvider 수정

```dart
// 기존:
// final canRecreateProvider = FutureProvider<bool>((ref) async {
//   final remaining = await ref.watch(remainingRecreationsProvider.future);
//   return remaining > 0;
// });

// 수정:
final canRecreateProvider = FutureProvider<bool>((ref) async {
  final isPremium = ref.watch(isPremiumProvider);
  if (isPremium) return true;

  final remaining = await ref.watch(remainingRecreationsProvider.future);
  return remaining > 0;
});
```

**필요 import 추가:**
```dart
import '../../subscription/providers/subscription_provider.dart';
```

## 6. Presentation 레이어

### 6.1 PaywallScreen (S18)

**파일:** `lib/features/subscription/presentation/paywall_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/constants/colors.dart';
import '../providers/subscription_provider.dart';

/// S18: Premium paywall screen.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isYearly = true;
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(offeringsProvider);

    return Scaffold(
      body: SafeArea(
        child: offeringsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _buildErrorState(),
          data: (offerings) {
            final offering = offerings.current;
            if (offering == null) return _buildErrorState();
            return _buildContent(offering);
          },
        ),
      ),
    );
  }

  Widget _buildContent(Offering offering) {
    final monthly = offering.monthly;
    final annual = offering.annual;

    return Column(
      children: [
        // Close button
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Header icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.premium,
                        AppColors.premium.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ClosetIQ 프리미엄',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textTitle,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '나만의 스타일을 제한 없이',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textBody,
                  ),
                ),
                const SizedBox(height: 32),

                // Benefits list
                _BenefitRow(
                  icon: Icons.checkroom,
                  title: '무제한 옷장',
                  subtitle: '30벌 제한 없이 모든 옷을 등록하세요',
                ),
                _BenefitRow(
                  icon: Icons.auto_awesome,
                  title: '무제한 룩 재현',
                  subtitle: '월 5회 제한 없이 마음껏 재현하세요',
                ),
                _BenefitRow(
                  icon: Icons.style,
                  title: '코디 버전 다양화',
                  subtitle: '3가지 코디 버전을 제안받으세요',
                ),
                _BenefitRow(
                  icon: Icons.analytics,
                  title: '상세 갭 분석',
                  subtitle: '부족한 아이템을 정확히 파악하세요',
                ),
                const SizedBox(height: 32),

                // Plan toggle
                _buildPlanToggle(monthly, annual),
                const SizedBox(height: 24),

                // Purchase button
                _buildPurchaseButton(monthly, annual),
                const SizedBox(height: 12),

                // Restore purchases
                TextButton(
                  onPressed: _restorePurchases,
                  child: Text(
                    '이전 구독 복원하기',
                    style: TextStyle(
                      color: AppColors.textCaption,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Legal text
                Text(
                  '구독은 선택한 기간에 따라 자동으로 갱신됩니다. '
                  '언제든지 설정에서 해지할 수 있습니다.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textCaption,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // TODO: Open terms URL
                      },
                      child: Text(
                        '이용약관',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textCaption,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(' | ',
                        style: TextStyle(color: AppColors.textCaption)),
                    TextButton(
                      onPressed: () {
                        // TODO: Open privacy URL
                      },
                      child: Text(
                        '개인정보처리방침',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textCaption,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanToggle(Package? monthly, Package? annual) {
    return Row(
      children: [
        Expanded(
          child: _PlanCard(
            isSelected: !_isYearly,
            label: '월간',
            price: monthly?.storeProduct.priceString ?? '₩6,900',
            period: '/월',
            onTap: () => setState(() => _isYearly = false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PlanCard(
            isSelected: _isYearly,
            label: '연간',
            price: annual?.storeProduct.priceString ?? '₩59,000',
            period: '/년',
            badge: '29% 할인',
            onTap: () => setState(() => _isYearly = true),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseButton(Package? monthly, Package? annual) {
    final selectedPackage = _isYearly ? annual : monthly;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isPurchasing || selectedPackage == null
            ? null
            : () => _purchase(selectedPackage),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.premium,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          disabledBackgroundColor: AppColors.premium.withValues(alpha: 0.5),
        ),
        child: _isPurchasing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                '구독하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Future<void> _purchase(Package package) async {
    setState(() => _isPurchasing = true);
    try {
      final service = ref.read(subscriptionServiceProvider);
      await service.purchase(package);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프리미엄 구독이 시작되었어요!')),
        );
      }
    } catch (e) {
      if (mounted) {
        // PurchaseCancelledException is not an error
        final isCancelled = e.toString().contains('PurchasesCancelled');
        if (!isCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('결제에 실패했어요. 다시 시도해주세요.')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restorePurchases() async {
    try {
      final service = ref.read(subscriptionServiceProvider);
      final info = await service.restorePurchases();
      if (mounted) {
        if (info.isPremium) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('구독이 복원되었어요!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('복원할 구독이 없어요.')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('복원에 실패했어요. 다시 시도해주세요.')),
        );
      }
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.textCaption),
          const SizedBox(height: 16),
          Text(
            '상품 정보를 불러올 수 없어요',
            style: TextStyle(color: AppColors.textBody),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.invalidate(offeringsProvider),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.premium.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.premium, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTitle,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textCaption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.isSelected,
    required this.label,
    required this.price,
    required this.period,
    required this.onTap,
    this.badge,
  });

  final bool isSelected;
  final String label;
  final String price;
  final String period;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.premium.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.premium : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (badge != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.premium,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? AppColors.premium : AppColors.textBody,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color:
                    isSelected ? AppColors.premium : AppColors.textTitle,
              ),
            ),
            Text(
              period,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textCaption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 6.2 SubscriptionManageScreen (S19)

**파일:** `lib/features/subscription/presentation/subscription_manage_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../data/models/subscription_status.dart';
import '../providers/subscription_provider.dart';

/// S19: Subscription management screen.
class SubscriptionManageScreen extends ConsumerWidget {
  const SubscriptionManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('구독 관리')),
      body: subAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _buildFreeState(context),
        data: (info) {
          if (!info.isPremium) return _buildFreeState(context);
          return _buildPremiumState(context, info);
        },
      ),
    );
  }

  Widget _buildFreeState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.workspace_premium,
              size: 64, color: AppColors.premium),
          const SizedBox(height: 16),
          const Text(
            '현재 무료 플랜을 사용 중이에요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textTitle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '프리미엄으로 업그레이드하고\n모든 기능을 제한 없이 사용하세요',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textBody,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PaywallScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premium,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                '프리미엄 시작하기',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumState(BuildContext context, SubscriptionInfo info) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Plan card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.premium,
                AppColors.premium.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.workspace_premium,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    info.plan?.displayName ?? '프리미엄',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (info.expiresAt != null) ...[
                const SizedBox(height: 12),
                Text(
                  '다음 결제: ${_formatDate(info.expiresAt!)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
              if (info.isInGracePeriod) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '결제 확인 필요',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Management options
        ListTile(
          leading:
              const Icon(Icons.swap_horiz, color: AppColors.textBody),
          title: const Text('플랜 변경'),
          subtitle: const Text('앱 스토어에서 플랜을 변경할 수 있어요'),
          trailing: const Icon(Icons.chevron_right,
              color: AppColors.textCaption),
          onTap: () => _openStoreSubscription(),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.cancel_outlined,
              color: AppColors.textBody),
          title: const Text('구독 해지'),
          subtitle: const Text('현재 기간 종료 후 무료 플랜으로 전환됩니다'),
          trailing: const Icon(Icons.chevron_right,
              color: AppColors.textCaption),
          onTap: () => _openStoreSubscription(),
        ),
      ],
    );
  }

  Future<void> _openStoreSubscription() async {
    // iOS: App Store subscription settings
    // Android: Google Play subscription settings
    final url = Uri.parse(
      'https://apps.apple.com/account/subscriptions',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}
```

**참고:** `PaywallScreen` import는 같은 패키지 내이므로 상대경로 사용:
```dart
import 'paywall_screen.dart';
```

### 6.3 LimitReachedSheet

**파일:** `lib/features/subscription/presentation/widgets/limit_reached_sheet.dart`

```dart
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../paywall_screen.dart';

/// Limit type for the bottom sheet.
enum LimitType { wardrobe, recreation }

/// Bottom sheet shown when free tier limit is reached.
class LimitReachedSheet extends StatelessWidget {
  const LimitReachedSheet({
    super.key,
    required this.limitType,
  });

  final LimitType limitType;

  /// Show as a modal bottom sheet.
  static Future<void> show(BuildContext context, LimitType type) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LimitReachedSheet(limitType: type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWardrobe = limitType == LimitType.wardrobe;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.premium.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isWardrobe ? Icons.checkroom : Icons.auto_awesome,
              color: AppColors.premium,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            isWardrobe ? '옷장이 꽉 찼어요!' : '이번 달 무료 횟수를 다 사용했어요',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textTitle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isWardrobe
                ? '프리미엄으로 업그레이드하면\n옷장 한도 없이 등록할 수 있어요'
                : '프리미엄으로 업그레이드하면\n매달 무제한으로 사용할 수 있어요',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textBody,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PaywallScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premium,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                '프리미엄으로 업그레이드',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Secondary action
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              isWardrobe ? '아이템 정리하기' : '다음 달까지 기다리기',
              style: TextStyle(color: AppColors.textCaption),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 7. 기존 UI 수정

### 7.1 SettingsScreen 수정

**파일:** `lib/features/settings/presentation/settings_screen.dart`

수정 포인트:
- 프로필 섹션: "무료 플랜" / "프리미엄" 상태 표시
- "프리미엄 업그레이드" → 구독 상태에 따라 분기

```dart
// 프로필 섹션 수정:
// 기존: Text('무료 플랜', ...)
// 수정:
Consumer(
  builder: (context, ref, _) {
    final isPremium = ref.watch(isPremiumProvider);
    return Text(
      isPremium ? '프리미엄' : '무료 플랜',
      style: TextStyle(
        fontSize: 14,
        color: isPremium ? AppColors.premium : AppColors.textCaption,
        fontWeight: isPremium ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  },
),

// "프리미엄 업그레이드" 타일 수정:
// 기존: onTap: () { // TODO: Navigate to premium upgrade }
// 수정:
Consumer(
  builder: (context, ref, _) {
    final isPremium = ref.watch(isPremiumProvider);
    return _SettingsTile(
      icon: Icons.workspace_premium,
      label: isPremium ? '구독 관리' : '프리미엄 업그레이드',
      iconColor: AppColors.premium,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => isPremium
                ? const SubscriptionManageScreen()
                : const PaywallScreen(),
          ),
        );
      },
    );
  },
),
```

**필요 import:**
```dart
import '../../subscription/providers/subscription_provider.dart';
import '../../subscription/presentation/paywall_screen.dart';
import '../../subscription/presentation/subscription_manage_screen.dart';
```

### 7.2 WardrobeScreen 수정

**파일:** `lib/features/wardrobe/presentation/wardrobe_screen.dart`

수정 포인트: 무료 한도 프로그레스바 → 프리미엄이면 숨김

```dart
// _buildProgressBar 호출부 수정:
// 기존: _buildProgressBar(count)
// 수정:
Consumer(
  builder: (context, ref, _) {
    final isPremium = ref.watch(isPremiumProvider);
    if (isPremium) return const SizedBox.shrink();
    return _buildProgressBar(count);
  },
),
```

### 7.3 ItemAddScreen 수정

**파일:** `lib/features/wardrobe/presentation/item_add_screen.dart`

수정 포인트: 한도 도달 시 LimitReachedSheet 표시

```dart
// 기존 canAdd 체크 부분 (약 line 83):
// 기존:
// final canAdd = await ref.read(canAddItemProvider.future);
// if (!canAdd) { /* 기존 경고 */ }

// 수정:
final canAdd = await ref.read(canAddItemProvider.future);
if (!canAdd && context.mounted) {
  LimitReachedSheet.show(context, LimitType.wardrobe);
  return;
}
```

## 8. 라우팅 수정

### AppRouter 수정

**파일:** `lib/core/router/app_router.dart`

```dart
// AppRoutes에 추가:
static const String paywall = '/paywall';
static const String subscriptionManage = '/subscription/manage';

// routes에 추가 (GoRoute 목록 안):
GoRoute(
  path: AppRoutes.paywall,
  builder: (context, state) => const PaywallScreen(),
),
GoRoute(
  path: AppRoutes.subscriptionManage,
  builder: (context, state) => const SubscriptionManageScreen(),
),
```

**필요 import:**
```dart
import '../../features/subscription/presentation/paywall_screen.dart';
import '../../features/subscription/presentation/subscription_manage_screen.dart';
```

## 9. 빌드 순서

| Step | 내용 | 파일 | 의존성 |
|------|------|------|--------|
| 1 | `purchases_flutter` 추가 | `pubspec.yaml` | 없음 |
| 2 | RevenueCatConfig 생성 | `lib/core/config/revenuecat_config.dart` | Step 1 |
| 3 | SubscriptionStatus 모델 | `lib/features/subscription/data/models/subscription_status.dart` | 없음 |
| 4 | SubscriptionService 생성 | `lib/features/subscription/data/subscription_service.dart` | Step 2, 3 |
| 5 | SubscriptionProvider 생성 | `lib/features/subscription/providers/subscription_provider.dart` | Step 4 |
| 6 | main.dart 수정 (RC 초기화) | `lib/main.dart` | Step 2 |
| 7 | PaywallScreen (S18) | `lib/features/subscription/presentation/paywall_screen.dart` | Step 5 |
| 8 | SubscriptionManageScreen (S19) | `lib/features/subscription/presentation/subscription_manage_screen.dart` | Step 5 |
| 9 | LimitReachedSheet 위젯 | `lib/features/subscription/presentation/widgets/limit_reached_sheet.dart` | Step 7 |
| 10 | 기존 Provider 수정 (canAddItem, canRecreate) | wardrobe_provider, usage_provider | Step 5 |
| 11 | 기존 UI 수정 (settings, wardrobe, item_add) | 기존 presentation 파일들 | Step 5, 7, 8, 9 |
| 12 | AppRouter에 라우트 추가 | `lib/core/router/app_router.dart` | Step 7, 8 |
| 13 | DB 마이그레이션 | `supabase/migrations/` | 없음 |
| 14 | flutter analyze + 검증 | — | 전체 |

## 10. 에러 처리

| 시나리오 | 처리 |
|----------|------|
| RevenueCat API 키 미설정 | `initialize()` 스킵, 모든 사용자 무료 취급 |
| RevenueCat SDK 초기화 실패 | catch → 무료 기본값, 앱은 정상 동작 |
| Offerings 로드 실패 | Paywall에 에러 상태 + 재시도 버튼 |
| 결제 취소 (사용자 의도) | `PurchasesCancelled` 감지 → 무시 (에러 메시지 안 보임) |
| 결제 실패 (네트워크/카드) | SnackBar 에러 메시지 + 재시도 안내 |
| 복원 실패 | SnackBar 에러 메시지 |
| 복원 성공 but 구독 없음 | "복원할 구독이 없어요" SnackBar |
| Grace period | `isPremium = true` 유지 + "결제 확인 필요" 뱃지 |
| 구독 만료 | `isPremium = false` → 자동으로 무료 한도 복원 |
