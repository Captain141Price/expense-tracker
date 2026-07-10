import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/setup/initial_balance_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/ledger/daily_ledger_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/settings/settings_screen.dart';

/// Route path constants used across the application.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String setup = '/setup';
  static const String home = '/home';
  static const String calendar = '/calendar';
  static const String ledger = '/ledger';
  static const String search = '/search';
  static const String settings = '/settings';

  /// Constructs the ledger path for a specific [date].
  ///
  /// Example: `/ledger/2026-07-09`
  static String ledgerPath(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$ledger/$y-$m-$d';
  }
}

/// Application router configuration using go_router.
///
/// First-launch flow:  Splash → Welcome → Setup (Initial Balance) → Home
/// Returning user:     Splash → Home
/// In-app navigation:  Home ↔ Calendar → Ledger (push)
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
        pageBuilder: (context, state) => _fadePage(
          state: state,
          child: const CalendarScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.ledger}/:date',
        pageBuilder: (context, state) {
          final dateString = state.pathParameters['date']!;
          final parts = dateString.split('-');
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          return _slidePage(
            state: state,
            child: DailyLedgerScreen(date: date),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (context, state) => _fadePage(
          state: state,
          child: const SearchScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => _fadePage(
          state: state,
          child: const SettingsScreen(),
        ),
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

  /// Builds a [CustomTransitionPage] with a horizontal slide — used for the
  /// Ledger screen pushed from the Calendar (feels like opening a page).
  ///
  /// Duration: 250 ms — matches UI_Guidelines animation range (200–300 ms).
  static CustomTransitionPage<void> _slidePage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1.0, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        final fade = CurvedAnimation(
          parent: animation,
          curve: const Interval(0, 0.5),
        );

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }
}
