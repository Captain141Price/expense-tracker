import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/transaction_entry.dart';
import '../../../../domain/enums/payment_mode.dart';
import '../../../../domain/enums/transaction_type.dart';

/// A single transaction row in the Daily Ledger.
///
/// Phase 3.1 layout (T3 — Title first, time secondary):
///
///   Title (ellipsized if long — T10)   +₹200.00
///   [UPI chip]  11:07 PM
///
/// Income is displayed in blue, expense in red.
/// Payment mode is shown as a compact Material 3 chip (T4 — uniform).
class LedgerTransactionItem extends StatelessWidget {
  const LedgerTransactionItem({super.key, required this.entry});

  final TransactionEntry entry;

  static final _timeFmt = DateFormat('h:mm a');

  String _modeLabel(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.upi:
        return 'UPI';
      case PaymentMode.card:
        return 'Card';
    }
  }

  IconData _modeIcon(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return Icons.payments_rounded;
      case PaymentMode.upi:
        return Icons.smartphone_rounded;
      case PaymentMode.card:
        return Icons.credit_card_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final prefix = isIncome ? '+' : '−';
    final timeLabel = _timeFmt.format(entry.dateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: Title + chip row ──────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title — single line with ellipsis (T10)
                Text(
                  entry.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),

                // Chip + time on the same row
                Row(
                  children: [
                    // ── Payment mode chip (T4 — uniform) ─────────────
                    _PaymentModeChip(
                      icon: _modeIcon(entry.paymentMode),
                      label: _modeLabel(entry.paymentMode),
                      color: color,
                    ),
                    const SizedBox(width: 8),

                    // ── Time (secondary) ──────────────────────────────
                    Text(
                      timeLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Right: Amount ────────────────────────────────────────────
          Text(
            '$prefix${CurrencyFormatter.format(entry.amount)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Payment Mode Chip (T4 — uniform height / padding / radius / icon / text) ─

class _PaymentModeChip extends StatelessWidget {
  const _PaymentModeChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 11, color: color.withValues(alpha: 0.85)),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color.withValues(alpha: 0.9),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
