import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/setup/initial_balance_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/calendar/calendar_screen.dart';

/// Route path constants used across the application.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String setup = '/setup';
  static const String home = '/home';
  static const String calendar = '/calendar';
}

/// Application router configuration using go_router.
///
/// First-launch flow:  Splash → Welcome → Setup (Initial Balance) → Home
/// Returning user:     Splash → Home
/// In-app navigation:  Home ↔ Calendar
abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (context, state) => _fadePage(
          state: state,
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.setup,
        pageBuilder: (context, state) => _fadePage(
          state: state,
          child: const InitialBalanceScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _fadePage(
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.calendar,
        builder: (context, state) => const CalendarScreen(),
      ),
    ],
  );

  /// Builds a [CustomTransitionPage] with a subtle fade + slight upward slide.
  ///
  /// Duration: 250 ms — matches UI_Guidelines animation range (200–300 ms).
  static CustomTransitionPage<void> _fadePage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ));

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }
}
