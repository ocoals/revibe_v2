import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// S09: Look recreation - reference image input
class ReferenceInputScreen extends StatelessWidget {
  const ReferenceInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('룩 재현')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '따라하고 싶은 코디 사진을\n선택해주세요',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Pick reference image from gallery
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('갤러리에서 선택'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '인스타그램 등에서 공유 버튼으로도\n이미지를 전달할 수 있어요',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textCaption,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
