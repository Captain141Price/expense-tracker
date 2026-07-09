import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/dashboard_summary.dart';

/// Displays the Total Balance prominently at the top of the Dashboard.
///
/// Phase 2.2 — Task 5: The balance amount animates with a 250 ms fade whenever
/// the value changes. [skipLoadingOnReload] prevents a loading-spinner flash
/// when the provider is invalidated after a transaction mutation; the old value
/// stays visible until the new value arrives, then the AnimatedSwitcher fires.
class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.summaryAsync});

  final AsyncValue<DashboardSummary> summaryAsync;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL BALANCE',
                style: AppTextStyles.labelMedium.copyWith(
                  letterSpacing: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              summaryAsync.when(
                // Task 5: keep previous data visible during reload to avoid
                // a spinner flash; AnimatedSwitcher fires on data→data change
                skipLoadingOnReload: true,
                data: (summary) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        key: ValueKey(summary.totalBalance),
                        CurrencyFormatter.format(summary.totalBalance),
                        style: AppTextStyles.headlineLarge,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Available Balance',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox(
                  height: 48,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (e, _) => Text(
                  '—',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
