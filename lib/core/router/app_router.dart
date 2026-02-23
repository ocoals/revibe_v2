import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/supabase_config.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/capture_screen.dart';
import '../../features/onboarding/presentation/confirm_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/wardrobe/presentation/wardrobe_screen.dart';
import '../../features/wardrobe/presentation/item_detail_screen.dart';
import '../../features/wardrobe/presentation/item_add_screen.dart';
import '../../features/wardrobe/presentation/item_register_screen.dart';
import '../../features/recreation/presentation/reference_input_screen.dart';
import '../../features/recreation/presentation/analyzing_screen.dart';
import '../../features/recreation/presentation/result_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

// Route paths
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String welcome = '/onboarding/welcome';
  static const String capture = '/onboarding/capture';
  static const String confirm = '/onboarding/confirm';
  static const String home = '/home';
  static const String wardrobe = '/wardrobe';
  static const String wardrobeDetail = '/wardrobe/:id';
  static const String wardrobeAdd = '/wardrobe/add';
  static const String wardrobeRegister = '/wardrobe/register';
  static const String recreation = '/recreation';
  static const String recreationAnalyzing = '/recreation/analyzing';
  static const String recreationResult = '/recreation/result/:id';
  static const String recreationGap = '/recreation/gap/:id';
  static const String settings = '/settings';
}

// Navigation shell key
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Onboarding status cache (reset on auth change)
bool? _cachedOnboardingCompleted;
String? _cachedUserId;

Future<bool> _isOnboardingCompleted() async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) return false;

  // Use cache if same user
  if (_cachedUserId == user.id && _cachedOnboardingCompleted != null) {
    return _cachedOnboardingCompleted!;
  }

  try {
    final profile = await SupabaseConfig.client
        .from('profiles')
        .select('onboarding_completed')
        .eq('id', user.id)
        .maybeSingle();
    _cachedOnboardingCompleted = profile?['onboarding_completed'] == true;
    _cachedUserId = user.id;
    return _cachedOnboardingCompleted!;
  } catch (_) {
    return true; // Assume completed on error to avoid blocking
  }
}

/// Call when onboarding is completed to update cache
void markOnboardingCompleted() {
  _cachedOnboardingCompleted = true;
}

/// Call on logout to reset cache
void resetOnboardingCache() {
  _cachedOnboardingCompleted = null;
  _cachedUserId = null;
}

/// Converts a Stream to a Listenable for GoRouter refresh
class _AuthStreamNotifier extends ChangeNotifier {
  late final StreamSubscription _subscription;

  _AuthStreamNotifier() {
    _subscription = SupabaseConfig.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(Ref ref) {
  final authNotifier = _AuthStreamNotifier();

  // Reset onboarding cache on auth state changes
  ref.listen(authStateProvider, (prev, next) {
    if (next.valueOrNull == null) {
      resetOnboardingCache();
    }
  });

  ref.onDispose(() => authNotifier.dispose());

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: authNotifier,
    redirect: (context, state) async {
      final isLoggedIn =
          SupabaseConfig.client.auth.currentSession != null;
      final isOnLoginPage = state.matchedLocation == AppRoutes.login;
      final isOnOnboarding =
          state.matchedLocation.startsWith('/onboarding');

      // Not logged in -> login
      if (!isLoggedIn && !isOnLoginPage) {
        return AppRoutes.login;
      }

      // Not logged in, already on login -> stay
      if (!isLoggedIn) return null;

      // Logged in: check onboarding status
      final onboardingDone = await _isOnboardingCompleted();

      // On login page -> go to onboarding or home
      if (isOnLoginPage) {
        return onboardingDone ? AppRoutes.home : AppRoutes.welcome;
      }

      // On main pages but onboarding not done -> redirect to onboarding
      if (!isOnOnboarding && !onboardingDone) {
        return AppRoutes.welcome;
      }

      return null;
    },
    routes: [
      // Login (outside shell)
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Onboarding (outside shell)
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.capture,
        builder: (context, state) => const CaptureScreen(),
      ),
      GoRoute(
        path: AppRoutes.confirm,
        builder: (context, state) => const ConfirmScreen(),
      ),

      // Main app with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.wardrobe,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WardrobeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.recreation,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReferenceInputScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),

      // Wardrobe routes (outside shell, full screen)
      // Literal paths must come before parameterized :id route
      GoRoute(
        path: AppRoutes.wardrobeAdd,
        builder: (context, state) => const ItemAddScreen(),
      ),
      GoRoute(
        path: AppRoutes.wardrobeRegister,
        builder: (context, state) => const ItemRegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.wardrobeDetail,
        builder: (context, state) => ItemDetailScreen(
          itemId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.recreationAnalyzing,
        builder: (context, state) => const AnalyzingScreen(),
      ),
      GoRoute(
        path: AppRoutes.recreationResult,
        builder: (context, state) => ResultScreen(
          recreationId: state.pathParameters['id']!,
        ),
      ),
      // GapAnalysisSheet is now shown as a bottom sheet from ResultScreen
    ],
  );
}

/// Main shell with bottom navigation
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.wardrobe)) return 1;
    if (location.startsWith(AppRoutes.recreation)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.wardrobe);
      case 2:
        context.go(AppRoutes.recreation);
      case 3:
        context.go(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
