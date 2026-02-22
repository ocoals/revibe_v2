import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/capture_screen.dart';
import '../../features/onboarding/presentation/confirm_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/wardrobe/presentation/wardrobe_screen.dart';
import '../../features/wardrobe/presentation/item_detail_screen.dart';
import '../../features/wardrobe/presentation/item_add_screen.dart';
import '../../features/recreation/presentation/reference_input_screen.dart';
import '../../features/recreation/presentation/analyzing_screen.dart';
import '../../features/recreation/presentation/result_screen.dart';
import '../../features/recreation/presentation/gap_analysis_sheet.dart';
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
  static const String recreation = '/recreation';
  static const String recreationAnalyzing = '/recreation/analyzing';
  static const String recreationResult = '/recreation/result/:id';
  static const String recreationGap = '/recreation/gap/:id';
  static const String settings = '/settings';
}

// Navigation shell key
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.valueOrNull != null;
      final isOnLoginPage = state.matchedLocation == AppRoutes.login;

      // Not logged in -> redirect to login
      if (!isLoggedIn && !isOnLoginPage) {
        return AppRoutes.login;
      }

      // Logged in but on login page -> redirect to home
      if (isLoggedIn && isOnLoginPage) {
        return AppRoutes.home;
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

      // Detail routes (outside shell, full screen)
      GoRoute(
        path: AppRoutes.wardrobeDetail,
        builder: (context, state) => ItemDetailScreen(
          itemId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.wardrobeAdd,
        builder: (context, state) => const ItemAddScreen(),
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
      GoRoute(
        path: AppRoutes.recreationGap,
        builder: (context, state) => GapAnalysisSheet(
          recreationId: state.pathParameters['id']!,
        ),
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
