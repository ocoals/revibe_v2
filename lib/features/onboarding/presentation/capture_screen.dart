import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// S03: Onboarding capture screen
/// Full implementation will use image_picker for camera/gallery
class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('옷장 시작하기')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              Container(
                width: 200,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '전신 가이드',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                '오늘 입은 옷을 찍어보세요!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '전신이 나오게 찍으면\n자동으로 아이템을 분리해드려요',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textBody,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Primary CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Launch camera via image_picker
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('지금 촬영하기'),
                ),
              ),
              const SizedBox(height: 12),
              // Secondary CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Open gallery via image_picker
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('갤러리에서 선택'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
