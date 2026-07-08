import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../router/app_router.dart';

/// Welcome screen — first screen shown on a fresh install.
///
/// Introduces the application and prompts the user to begin setup.
/// Navigates to [AppRoutes.setup] (Initial Balance screen) on Continue.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // ─── Icon ──────────────────────────────────────────────────
              const Icon(
                Icons.account_balance_wallet_rounded,
                size: 56,
                color: AppColors.income,
              ),

              const SizedBox(height: 24),

              // ─── App name ──────────────────────────────────────────────
              Text(
                'Expense Notebook',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 8),

              // ─── Welcome heading ───────────────────────────────────────
              Text(
                '👋 Welcome',
                style: AppTextStyles.headlineLarge,
              ),

              const SizedBox(height: 24),

              // ─── Description ───────────────────────────────────────────
              Text(
                'Track your income and expenses\nlike writing in a notebook.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 16),

              // ─── Setup duration note ───────────────────────────────────
              Text(
                'This setup only takes a few seconds.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),

              const Spacer(flex: 3),

              // ─── Continue button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.setup),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.income,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
