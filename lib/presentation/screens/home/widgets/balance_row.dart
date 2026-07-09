import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/dashboard_summary.dart';

/// Displays Cash Balance and Digital Balance side-by-side.
///
/// Each item is a separate Card so they expand equally and align cleanly.
///
/// Phase 2.2 — Task 5: balance values animate with a 250 ms fade on change.
class BalanceRow extends StatelessWidget {
  const BalanceRow({super.key, required this.summaryAsync});

  final AsyncValue<DashboardSummary> summaryAsync;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BalanceItem(
            label: 'Digital Balance',
            icon: Icons.account_balance_rounded,
            valueAsync: summaryAsync.whenData((s) => s.digitalBalance),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BalanceItem(
            label: 'Cash Balance',
            icon: Icons.payments_rounded,
            valueAsync: summaryAsync.whenData((s) => s.cashBalance),
          ),
        ),
      ],
    );
  }
}

/// Single balance item used inside [BalanceRow].
class _BalanceItem extends StatelessWidget {
  const _BalanceItem({
    required this.label,
    required this.icon,
    required this.valueAsync,
  });

  final String label;
  final IconData icon;
  final AsyncValue<double> valueAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Task 5: animate balance value on change; skip reload spinner
            valueAsync.when(
              skipLoadingOnReload: true,
              data: (value) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  key: ValueKey(value),
                  CurrencyFormatter.format(value),
                  style: AppTextStyles.titleMedium,
                ),
              ),
              loading: () => const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (e, _) => Text(
                '—',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
