import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';

/// A balance tile showing a labelled amount.
///
/// Used for Opening Balance and Closing Balance in the Daily Ledger.
///
/// Phase 3.1 (T5 — uniform card consistency):
/// - Identical padding (all(16)) to Transactions and Daily Summary cards.
/// - Same border radius and elevation as theme CardTheme (16, 0).
/// - Label uses textSecondary / titleSmall; amount uses bodyLarge w600.
/// - Closing balance amount is titleMedium w700 to emphasise the final result.
///
/// Layout (inside a Card):
///   Opening Balance       ₹22,010.00
class LedgerBalanceTile extends StatelessWidget {
  const LedgerBalanceTile({
    super.key,
    required this.label,
    required this.amount,
    this.isClosing = false,
  });

  final String label;
  final double amount;

  /// When true, the amount is emphasised with titleMedium w700.
  final bool isClosing;

  @override
  Widget build(BuildContext context) {
    return Card(
      // Explicit margin: zero — spacing is managed by the parent Column.
      margin: EdgeInsets.zero,
      child: Padding(
        // Identical to LedgerSummaryCard and _TransactionSection (T5).
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              CurrencyFormatter.format(amount),
              style: isClosing
                  ? AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )
                  : AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
