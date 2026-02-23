import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/router/app_router.dart';

/// S04: Onboarding item confirmation screen
/// Shows detected items after background removal & color extraction
class ConfirmScreen extends StatelessWidget {
  const ConfirmScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user != null) {
      try {
        await SupabaseConfig.client.from('profiles').update({
          'onboarding_completed': true,
        }).eq('id', user.id);
      } catch (_) {}
    }
    markOnboardingCompleted();
    if (context.mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('아이템 확인')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '아이템을 찾았어요!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '카테고리를 확인하고 옷장에 추가해보세요',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textBody,
                ),
              ),
              const SizedBox(height: 24),

              // Placeholder for detected items list
              Expanded(
                child: Center(
                  child: Text(
                    '감지된 아이템이 여기에 표시됩니다',
                    style: TextStyle(color: AppColors.textCaption),
                  ),
                ),
              ),

              // Bottom CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _completeOnboarding(context),
                  child: const Text('옷장에 추가하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
