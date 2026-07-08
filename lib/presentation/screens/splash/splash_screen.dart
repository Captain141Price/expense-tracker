import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/providers.dart';
import '../../router/app_router.dart';

/// Splash screen shown on application launch.
///
/// Startup flow:
///   1. Display branding with a fade-in animation (900 ms).
///   2. After 2 seconds, read [appSettingsProvider] to check first-launch status.
///   3. Route decision:
///      - No settings row (fresh install) → [AppRoutes.welcome]
///      - Settings row exists             → [AppRoutes.home]
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), _resolveStartupRoute);
  }

  /// Reads [appSettingsProvider] and navigates to the correct screen.
  ///
  /// Falls back to [AppRoutes.home] on any provider error to avoid
  /// leaving the user stuck on the splash screen.
  Future<void> _resolveStartupRoute() async {
    if (!mounted) return;

    final settingsAsync = ref.read(appSettingsProvider);

    settingsAsync.when(
      data: (settings) {
        if (!mounted) return;
        final isFirst = settings == null || settings.isFirstLaunch;
        context.go(isFirst ? AppRoutes.welcome : AppRoutes.home);
      },
      loading: () {
        // Provider still loading — wait for the listener below to fire.
      },
      error: (e, _) {
        if (mounted) context.go(AppRoutes.home);
      },
    );

    // If the provider was still loading, listen for when it resolves.
    if (settingsAsync.isLoading) {
      ref.listenManual(appSettingsProvider, (_, next) {
        next.whenData((settings) {
          if (!mounted) return;
          final isFirst = settings == null || settings.isFirstLaunch;
          context.go(isFirst ? AppRoutes.welcome : AppRoutes.home);
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 72,
                color: Color(0xFF4A90D9),
              ),
              SizedBox(height: 20),
              Text(
                'Expense Notebook',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF5F5F5),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Track every rupee.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
