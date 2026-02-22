import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// S08: Add item (camera -> background removal -> registration)
class ItemAddScreen extends StatelessWidget {
  const ItemAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('아이템 추가')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 24),
              const Text(
                '옷을 촬영해주세요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '배경이 깔끔할수록\n더 정확하게 인식해요',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textBody,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Launch camera
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('카메라로 촬영'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Open gallery
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('갤러리에서 선택'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
