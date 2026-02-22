import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// S11: Look recreation result
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.recreationId});

  final String recreationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('룩 재현 결과'),
        actions: [
          // Match score badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '매칭 ---%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Recreation: $recreationId',
          style: TextStyle(color: AppColors.textCaption),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Save image
                  },
                  icon: const Icon(Icons.save_alt),
                  label: const Text('이미지 저장'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Share
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('공유하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
