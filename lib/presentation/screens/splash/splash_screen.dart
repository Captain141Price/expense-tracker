import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/providers.dart';
import '../../../data/local/app_startup_helper.dart';
import '../../router/app_router.dart';

/// Splash screen shown on application launch.
///
/// Startup flow:
///   1. Display branding with a fade-in animation.
///   2. Initialise the database via [databaseProvider].
///   3. Use [AppStartupHelper.isFirstLaunch] to decide the next route.
///      - First launch  → [AppRoutes.setup]  (Initial Setup — Phase 1)
///      - Returning     → [AppRoutes.home]
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

  /// Checks [AppStartupHelper.isFirstLaunch] and navigates accordingly.
  ///
  /// Falls back to [AppRoutes.home] if the database is not yet available
  /// (AsyncValue is loading or in error state) to keep the UI unblocked.
  Future<void> _resolveStartupRoute() async {
    if (!mounted) return;

    final dbAsync = ref.read(databaseProvider);

    await dbAsync.when(
      data: (db) async {
        final helper = AppStartupHelper(db);
        final firstLaunch = await helper.isFirstLaunch();
        if (!mounted) return;
        // /setup will be fully wired in Phase 1.
        // Until then, first-launch also routes to home.
        context.go(firstLaunch ? AppRoutes.home : AppRoutes.home);
      },
      loading: () {
        if (mounted) context.go(AppRoutes.home);
      },
      error: (e, _) {
        if (mounted) context.go(AppRoutes.home);
      },
    );
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

