import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';
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
          const Icon(Icons.workspace_premium,
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
          const Text(
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
              onPressed: () => context.push(AppRoutes.paywall),
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
    final url = Uri.parse(
      Platform.isIOS
          ? 'https://apps.apple.com/account/subscriptions'
          : 'https://play.google.com/store/account/subscriptions',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}
