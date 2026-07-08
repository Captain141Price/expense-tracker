import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/calendar/calendar_screen.dart';

/// Route path constants used across the application.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String setup = '/setup';
  static const String home = '/home';
  static const String calendar = '/calendar';
}

/// Application router configuration using go_router.
///
/// Initial location is the Splash screen.
/// Startup flow: Splash → (first launch?) → Setup → Home | Home
/// In-app navigation: Home ↔ Calendar
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
      // /setup route will be wired to InitialSetupScreen in Phase 1.
    ],
  );
}

