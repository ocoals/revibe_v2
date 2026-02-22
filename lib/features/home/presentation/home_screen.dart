import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';

/// S05: Home Dashboard
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textCaption,
                          ),
                        ),
                        const Text(
                          '오늘도 스타일리시하게!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textTitle,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => context.go(AppRoutes.settings),
                      icon: const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _QuickActionButton(
                      icon: Icons.camera_alt,
                      label: '촬영',
                      onTap: () => context.push(AppRoutes.wardrobeAdd),
                    ),
                    const SizedBox(width: 12),
                    _QuickActionButton(
                      icon: Icons.auto_awesome,
                      label: '룩재현',
                      onTap: () => context.go(AppRoutes.recreation),
                    ),
                    const SizedBox(width: 12),
                    _QuickActionButton(
                      icon: Icons.edit_note,
                      label: '기록',
                      onTap: () {
                        // TODO: Daily outfit recording (Tier 2)
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Wardrobe Preview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '내 옷장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTitle,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.wardrobe),
                      child: const Text('전체보기'),
                    ),
                  ],
                ),
              ),
            ),

            // Wardrobe items horizontal scroll placeholder
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    '옷장에 아이템을 추가해보세요',
                    style: TextStyle(color: AppColors.textCaption),
                  ),
                ),
              ),
            ),

            // Recent Recreation
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: const Text(
                  '최근 룩 재현',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTitle,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: AppColors.primary),
                        const SizedBox(height: 8),
                        Text(
                          '인플루언서 룩을 내 옷으로 재현해보세요',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textBody,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
