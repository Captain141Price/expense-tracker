import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Daily Summary card shown in the Daily Ledger.
///
/// Phase 3.1 (T5 — uniform card consistency):
/// - Explicit margin: zero — spacing managed by parent Column.
/// - Identical padding (all(16)) to LedgerBalanceTile and _TransactionSection.
///
/// Displays:
///   Income        ₹500.00  (blue)
///   Expense       ₹120.00  (red)
///   ─────────────────────────
///   Net          +₹380.00  (blue / red)
///   ─────────────────────────
///   Transactions  3
class LedgerSummaryCard extends StatelessWidget {
  const LedgerSummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.transactionCount,
  });

  final double totalIncome;
  final double totalExpense;
  final int transactionCount;

  double get _net => totalIncome - totalExpense;

  @override
  Widget build(BuildContext context) {
    final netColor = _net >= 0 ? AppColors.income : AppColors.expense;
    final netPrefix = _net >= 0 ? '+' : '−';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Summary',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ── Income ─────────────────────────────────────────────────
            _SummaryRow(
              label: 'Income',
              value: CurrencyFormatter.format(totalIncome),
              color: AppColors.income,
            ),
            const SizedBox(height: 8),

            // ── Expense ────────────────────────────────────────────────
            _SummaryRow(
              label: 'Expense',
              value: CurrencyFormatter.format(totalExpense),
              color: AppColors.expense,
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // ── Net ────────────────────────────────────────────────────
            _SummaryRow(
              label: 'Net',
              value: '$netPrefix${CurrencyFormatter.format(_net.abs())}',
              color: netColor,
              bold: true,
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // ── Transaction count ──────────────────────────────────────
            _SummaryRow(
              label: 'Transactions',
              value: '$transactionCount',
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
