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
import '../../features/wardrobe/presentation/wardrobe_screen.dart';
import '../../features/wardrobe/presentation/item_detail_screen.dart';
import '../../features/wardrobe/presentation/item_add_screen.dart';
import '../../features/wardrobe/presentation/item_register_screen.dart';
import '../../features/recreation/presentation/reference_input_screen.dart';
import '../../features/recreation/presentation/analyzing_screen.dart';
import '../../features/recreation/presentation/result_screen.dart';
import '../../features/daily/presentation/calendar_screen.dart';
import '../../features/daily/presentation/daily_record_screen.dart';
import '../../features/daily/presentation/wardrobe_picker_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/subscription/presentation/paywall_screen.dart';
import '../../features/subscription/presentation/subscription_manage_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

// Route paths
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String welcome = '/onboarding/welcome';
  static const String capture = '/onboarding/capture';
  static const String confirm = '/onboarding/confirm';
  static const String wardrobe = '/wardrobe';
  static const String wardrobeDetail = '/wardrobe/:id';
  static const String wardrobeAdd = '/wardrobe/add';
  static const String wardrobeRegister = '/wardrobe/register';
  static const String recreation = '/recreation';
  static const String recreationAnalyzing = '/recreation/analyzing';
  static const String recreationResult = '/recreation/result/:id';
  static const String recreationGap = '/recreation/gap/:id';
  static const String daily = '/daily';
  static const String settings = '/settings';
  static const String dailyRecordCreate = '/daily-record/create';
  static const String dailyRecordPickItems = '/daily-record/pick-items';
  static const String paywall = '/paywall';
  static const String subscriptionManage = '/subscription/manage';
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

// Pending onboarding skip flag (set by Welcome "건너뛰기" button)
bool _pendingOnboardingSkip = false;

void setPendingOnboardingSkip(bool value) {
  _pendingOnboardingSkip = value;
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
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    redirect: (context, state) async {
      final isLoggedIn =
          SupabaseConfig.client.auth.currentSession != null;
      final isOnSplash = state.matchedLocation == AppRoutes.splash;
      final isOnLoginPage = state.matchedLocation == AppRoutes.login;
      final isOnOnboarding =
          state.matchedLocation.startsWith('/onboarding');

      // Splash screen: don't redirect
      if (isOnSplash) return null;

      // Not logged in
      if (!isLoggedIn) {
        // Allow access to login and onboarding pages
        if (isOnLoginPage || isOnOnboarding) return null;
        // Redirect to Welcome (not Login — onboarding first)
        return AppRoutes.welcome;
      }

      // --- Logged in ---

      // On login page: determine post-login destination
      if (isOnLoginPage) {
        if (_pendingOnboardingSkip) {
          // "건너뛰기" was pressed: mark onboarding complete
          _pendingOnboardingSkip = false;
          final user = SupabaseConfig.client.auth.currentUser;
          if (user != null) {
            try {
              await SupabaseConfig.client.from('profiles').update({
                'onboarding_completed': true,
              }).eq('id', user.id);
            } catch (_) {}
          }
          markOnboardingCompleted();
          return AppRoutes.wardrobe;
        }
        final onboardingDone = await _isOnboardingCompleted();
        return onboardingDone ? AppRoutes.wardrobe : AppRoutes.capture;
      }

      // On onboarding pages (capture/confirm): allow
      if (isOnOnboarding) return null;

      // On main pages but onboarding not done: redirect to Capture
      final onboardingDone = await _isOnboardingCompleted();
      if (!onboardingDone) {
        return AppRoutes.capture;
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Login (outside shell)
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Onboarding (outside shell)
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (context, state) {
          final initialPage = state.extra as int? ?? 0;
          // 로그인에서 돌아올 때(initialPage > 0) 왼쪽에서 슬라이드
          if (initialPage > 0) {
            return CustomTransitionPage(
              child: WelcomeScreen(initialPage: initialPage),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ));
                return SlideTransition(position: offsetAnimation, child: child);
              },
            );
          }
          return MaterialPage(child: WelcomeScreen(initialPage: initialPage));
        },
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
            path: AppRoutes.daily,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(),
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

      // Daily Record routes (outside shell, full screen)
      GoRoute(
        path: AppRoutes.dailyRecordCreate,
        builder: (context, state) {
          final dateStr = state.uri.queryParameters['date'];
          final date =
              dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
          return DailyRecordScreen(initialDate: date);
        },
      ),
      GoRoute(
        path: AppRoutes.dailyRecordPickItems,
        builder: (context, state) {
          final date = state.extra as DateTime;
          return WardrobePickerScreen(date: date);
        },
      ),

      // Subscription routes
      GoRoute(
        path: AppRoutes.paywall,
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscriptionManage,
        builder: (context, state) => const SubscriptionManageScreen(),
      ),
    ],
  );
}

/// Main shell with bottom navigation
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.wardrobe)) return 0;
    if (location.startsWith(AppRoutes.recreation)) return 1;
    if (location.startsWith(AppRoutes.daily)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.wardrobe);
      case 1:
        context.go(AppRoutes.recreation);
      case 2:
        context.go(AppRoutes.daily);
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
