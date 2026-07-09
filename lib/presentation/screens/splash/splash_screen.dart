import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/providers.dart';
import '../../router/app_router.dart';

/// Splash screen shown on application launch.
///
/// Startup flow:
///   1. Display branding with a fade-in animation (900 ms).
///   2. After a 2-second minimum display period the screen is "ready to navigate".
///   3. [appSettingsProvider] is watched in [build] via [ref.listen].
///      As soon as both conditions are true (timer elapsed + data resolved),
///      the screen navigates:
///      - No settings row (fresh install) → [AppRoutes.welcome]
///      - Settings row with isFirstLaunch = false → [AppRoutes.home]
///
/// Using [ref.listen] in [build] ensures Riverpod manages the subscription
/// lifetime and there is no risk of a dangling [listenManual] subscription.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  /// Set to `true` after the minimum 2-second display period elapses.
  bool _readyToNavigate = false;

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

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _readyToNavigate = true);
        // If the provider has already resolved by the time the timer fires,
        // _tryNavigate will handle it immediately from the current state.
        _tryNavigate(ref.read(appSettingsProvider));
      }
    });
  }

  /// Navigates away when [_readyToNavigate] is true and [settingsAsync]
  /// contains resolved data. A no-op in all other states.
  void _tryNavigate(AsyncValue<dynamic> settingsAsync) {
    if (!_readyToNavigate || !mounted) return;

    settingsAsync.when(
      data: (settings) {
        final isFirst = settings == null || settings.isFirstLaunch;
        context.go(isFirst ? AppRoutes.welcome : AppRoutes.home);
      },
      loading: () {
        // Data not ready yet — the ref.listen in build() will retry.
      },
      error: (e, _) {
        // On database error fall back to Home to avoid leaving the user stuck.
        context.go(AppRoutes.home);
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
    // ref.listen is managed by Riverpod — subscription is automatically
    // cancelled when this widget is disposed. Fires every time the provider
    // emits a new value (loading → data, loading → error, etc.).
    ref.listen<AsyncValue<dynamic>>(appSettingsProvider, (_, next) {
      _tryNavigate(next);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
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
                  color: Color(0xFFFFFFFF),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Track every rupee.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFB0B0B0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
