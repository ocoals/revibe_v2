import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

/// Stream of auth state changes
final authStateProvider = StreamProvider<Session?>((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange.map(
    (event) => event.session,
  );
});

/// Current user (reactive to auth state changes)
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateProvider);
  return SupabaseConfig.client.auth.currentUser;
});

/// Auth actions
class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Sign in with Kakao OAuth
  Future<void> signInWithKakao() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.kakao,
      redirectTo: 'com.closetiq.closetiq://login-callback',
    );
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'com.closetiq.closetiq://login-callback',
    );
  }

  /// Sign up with email + password
  Future<void> signUpWithEmail(String email, String password) async {
    await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign in with email + password
  Future<void> signInWithEmail(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
