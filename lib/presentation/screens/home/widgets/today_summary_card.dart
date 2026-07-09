import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/dashboard_summary.dart';

/// Shows Today's Income, Expense, and Net in a single card.
///
/// Income is blue, Expense is red, Net is coloured based on sign.
/// The three columns are separated by thin vertical dividers rendered via
/// [IntrinsicHeight] so they stretch to match the tallest sibling.
class TodaySummaryCard extends StatelessWidget {
  const TodaySummaryCard({super.key, required this.summaryAsync});

  final AsyncValue<DashboardSummary> summaryAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Summary",
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            summaryAsync.when(
              data: (summary) {
                final netColor = summary.todayNet >= 0
                    ? AppColors.income
                    : AppColors.expense;
                return IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryItem(
                          label: 'Income',
                          value: summary.todayIncome,
                          color: AppColors.income,
                        ),
                      ),
                      const VerticalDivider(
                        width: 24,
                        thickness: 1,
                        color: AppColors.divider,
                      ),
                      Expanded(
                        child: _SummaryItem(
                          label: 'Expense',
                          value: summary.todayExpense,
                          color: AppColors.expense,
                        ),
                      ),
                      const VerticalDivider(
                        width: 24,
                        thickness: 1,
                        color: AppColors.divider,
                      ),
                      Expanded(
                        child: _SummaryItem(
                          label: 'Net',
                          value: summary.todayNet,
                          color: netColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: SizedBox(
                  height: 40,
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text(
                'Unable to load summary.',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single labelled value cell used inside [TodaySummaryCard].
class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.format(value),
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
