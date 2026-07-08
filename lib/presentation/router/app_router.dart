import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/calendar/calendar_screen.dart';

/// Route path constants used across the application.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String calendar = '/calendar';
}

/// Application router configuration using go_router.
///
/// Initial location is the Splash screen.
/// Navigation flows: Splash → Home ↔ Calendar
abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.calendar,
        builder: (context, state) => const CalendarScreen(),
      ),
    ],
  );
}
