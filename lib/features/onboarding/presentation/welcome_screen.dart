import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              const Icon(
                Icons.checkroom,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                '옷장을 시작해볼까요?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '오늘 입은 옷 한 장이면\n30초 만에 옷장이 만들어져요',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textBody,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.capture),
                  child: const Text('오늘 입은 옷 찍기'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(
                  '나중에 할게요',
                  style: TextStyle(color: AppColors.textCaption),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
