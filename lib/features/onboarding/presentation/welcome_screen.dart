import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/router/app_router.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.checkroom,
      title: '내 옷장을 AI로 관리해요',
      description: '사진 한 장이면 자동으로\n카테고리, 색상, 스타일을 분석해요',
    ),
    _SlideData(
      icon: Icons.auto_awesome,
      title: '인플루언서 룩을 내 옷으로',
      description: '좋아하는 룩을 내 옷장에서\n비슷한 아이템으로 재현해드려요',
    ),
    _SlideData(
      icon: Icons.camera_alt,
      title: '시작은 오늘 입은 옷 한 장',
      description: '지금 입고 있는 옷을 찍으면\n30초 만에 옷장이 만들어져요',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _skipOnboarding() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user != null) {
      try {
        await SupabaseConfig.client.from('profiles').update({
          'onboarding_completed': true,
        }).eq('id', user.id);
      } catch (_) {}
    }
    markOnboardingCompleted();
    if (mounted) context.go(AppRoutes.home);
  }

  void _goToCapture() {
    context.push(AppRoutes.capture);
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: back button + skip button
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4, right: 16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      icon: const Icon(Icons.arrow_back),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      '건너뛰기',
                      style: TextStyle(
                        color: AppColors.textCaption,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          slide.icon,
                          size: 80,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textTitle,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textBody,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page indicator dots
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => Container(
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLastPage
                      ? _goToCapture
                      : () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  child: Text(isLastPage ? '오늘 입은 옷 찍기' : '다음'),
                ),
              ),
            ),

            // "나중에 할게요" on last page
            if (isLastPage)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    '나중에 할게요',
                    style: TextStyle(color: AppColors.textCaption),
                  ),
                ),
              )
            else
              const SizedBox(height: 48), // Spacing to match layout
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  final IconData icon;
  final String title;
  final String description;

  const _SlideData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
