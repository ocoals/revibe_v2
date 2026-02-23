import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false; // false = 로그인, true = 회원가입
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      _showError('올바른 이메일을 입력해주세요');
      return;
    }
    if (password.length < 6) {
      _showError('비밀번호는 6자 이상이어야 해요');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      if (_isSignUp) {
        await authService.signUpWithEmail(email, password);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입 완료! 로그인됩니다')),
          );
        }
      } else {
        await authService.signInWithEmail(email, password);
      }
    } catch (e) {
      if (mounted) {
        final message = _isSignUp
            ? '회원가입에 실패했어요. 이미 가입된 이메일일 수 있어요'
            : '로그인에 실패했어요. 이메일과 비밀번호를 확인해주세요';
        _showError(message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Logo & tagline
                const Text(
                  'ClosetIQ',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '내 옷으로 인플루언서 룩을',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textBody,
                  ),
                ),

                const Spacer(flex: 2),

                // Kakao Login
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => authService.signInWithKakao(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEE500),
                      foregroundColor: const Color(0xFF191919),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '카카오로 시작하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Apple Login
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => authService.signInWithApple(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apple로 시작하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '또는',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textCaption,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),

                const SizedBox(height: 24),

                // Email input
                SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: '이메일 주소',
                      hintStyle: TextStyle(color: AppColors.textCaption),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Password input
                SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '비밀번호',
                      hintStyle: TextStyle(color: AppColors.textCaption),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textCaption,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(
                              () => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Email auth button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleEmailAuth,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _isSignUp ? '회원가입' : '이메일로 로그인',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // Toggle login/signup
                TextButton(
                  onPressed: () {
                    setState(() => _isSignUp = !_isSignUp);
                  },
                  child: Text(
                    _isSignUp
                        ? '이미 계정이 있으신가요? 로그인'
                        : '계정이 없으신가요? 회원가입',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textBody,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Terms
                Text(
                  '시작하면 이용약관과 개인정보처리방침에 동의합니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textCaption,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
