import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../../wardrobe/providers/wardrobe_provider.dart';
import '../../recreation/providers/recreation_provider.dart';

/// Profile / Settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final countAsync = ref.watch(wardrobeCountProvider);
    final historyAsync = ref.watch(recreationHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
          child: Column(
            children: [
              // Profile section — white bg with border, extends behind status bar
              Container(
                padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 18),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: AppColors.divider, width: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar + name row
                    Row(
                      children: [
                        // R circle avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.background,
                          ),
                          child: const Center(
                            child: Text(
                              'R',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontFamily: 'Georgia',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '사용자',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textTitle,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              isPremium ? '프리미엄' : '무료 플랜',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textCaption,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stats row — bg color background
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _StatItem(
                            label: '내 옷',
                            value: countAsync.when(
                              data: (c) => '$c',
                              loading: () => '-',
                              error: (_, _) => '-',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 28,
                            color: AppColors.lineDark,
                          ),
                          _StatItem(
                            label: '룩 재현',
                            value: historyAsync.when(
                              data: (h) => '${h.length}',
                              loading: () => '-',
                              error: (_, _) => '-',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 28,
                            color: AppColors.lineDark,
                          ),
                          const _StatItem(
                            label: '데일리',
                            value: '-',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Premium upgrade card — primary solid bg
                    if (!isPremium)
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.paywall),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '프리미엄으로 업그레이드',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '옷장 무제한 · 재현 무제한 · 데일리 코디',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white
                                          .withValues(alpha: 0.55),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '₩4,900',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Settings list — no icons, just text + chevron
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (isPremium)
                            _SettingsItem(
                              label: '구독 관리',
                              onTap: () => context
                                  .push(AppRoutes.subscriptionManage),
                            ),
                          _SettingsItem(
                            label: '알림 설정',
                            onTap: () {},
                          ),
                          _SettingsItem(
                            label: '자주 묻는 질문',
                            onTap: () {},
                          ),
                          _SettingsItem(
                            label: '문의하기',
                            onTap: () {},
                          ),
                          _SettingsItem(
                            label: '이용약관',
                            onTap: () => launchUrl(
                              Uri.parse('https://closetiq.app/terms'),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                          _SettingsItem(
                            label: '개인정보처리방침',
                            onTap: () => launchUrl(
                              Uri.parse('https://closetiq.app/privacy'),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                          _SettingsItem(
                            label: '앱 버전 1.0.0',
                            isLast: true,
                            isVersion: true,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Logout
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async {
                          final authService =
                              ref.read(authServiceProvider);
                          await authService.signOut();
                        },
                        child: const Text(
                          '로그아웃',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textCaption,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textTitle,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textCaption,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.label,
    required this.onTap,
    this.isLast = false,
    this.isVersion = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLast;
  final bool isVersion;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isVersion
                        ? AppColors.textCaption
                        : AppColors.textTitle,
                  ),
                ),
                if (!isVersion)
                  const Icon(Icons.chevron_right,
                      size: 14, color: AppColors.mute),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 0.5, color: AppColors.divider),
          ),
      ],
    );
  }
}
