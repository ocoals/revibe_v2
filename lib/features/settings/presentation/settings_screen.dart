import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../auth/providers/auth_provider.dart';

/// S13: Settings / My page
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이')),
      body: ListView(
        children: [
          // Profile section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '사용자',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTitle,
                      ),
                    ),
                    Text(
                      '무료 플랜',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textCaption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          _SettingsTile(
            icon: Icons.workspace_premium,
            label: '프리미엄 업그레이드',
            iconColor: AppColors.premium,
            onTap: () {
              // TODO: Navigate to premium upgrade
            },
          ),
          _SettingsTile(
            icon: Icons.calendar_month,
            label: '코디 캘린더',
            onTap: () {
              // TODO: Navigate to calendar (Tier 2)
            },
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: '알림 설정',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            label: '개인정보처리방침',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            label: '서비스 이용약관',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            label: '앱 버전',
            trailing: Text(
              '0.1.0',
              style: TextStyle(color: AppColors.textCaption),
            ),
            onTap: () {},
          ),

          const Divider(),

          _SettingsTile(
            icon: Icons.logout,
            label: '로그아웃',
            iconColor: AppColors.error,
            textColor: AppColors.error,
            onTap: () async {
              final authService = ref.read(authServiceProvider);
              await authService.signOut();
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textBody),
      title: Text(
        label,
        style: TextStyle(
          color: textColor ?? AppColors.textTitle,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: AppColors.textCaption),
      onTap: onTap,
    );
  }
}
