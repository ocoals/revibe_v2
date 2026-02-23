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
                const Text(
                  '나만의 스타일을 제한 없이',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textBody,
                  ),
                ),
                const SizedBox(height: 32),

                // Benefits list
                const _BenefitRow(
                  icon: Icons.checkroom,
                  title: '무제한 옷장',
                  subtitle: '30벌 제한 없이 모든 옷을 등록하세요',
                ),
                const _BenefitRow(
                  icon: Icons.auto_awesome,
                  title: '무제한 룩 재현',
                  subtitle: '월 5회 제한 없이 마음껏 재현하세요',
                ),
                const _BenefitRow(
                  icon: Icons.style,
                  title: '코디 버전 다양화',
                  subtitle: '3가지 코디 버전을 제안받으세요',
                ),
                const _BenefitRow(
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
                  child: const Text(
                    '이전 구독 복원하기',
                    style: TextStyle(
                      color: AppColors.textCaption,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Legal text
                const Text(
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
                      child: const Text(
                        '이용약관',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textCaption,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Text(' | ',
                        style: TextStyle(color: AppColors.textCaption)),
                    TextButton(
                      onPressed: () {
                        // TODO: Open privacy URL
                      },
                      child: const Text(
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
          const Icon(Icons.error_outline, size: 48, color: AppColors.textCaption),
          const SizedBox(height: 16),
          const Text(
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
                  style: const TextStyle(
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
              style: const TextStyle(
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
