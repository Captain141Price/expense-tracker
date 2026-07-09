import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/providers/providers.dart';
import '../../../../domain/entities/transaction_entry.dart';
import '../../../../domain/enums/payment_mode.dart';
import '../../../../domain/enums/transaction_type.dart';
import '../../../widgets/add_transaction_sheet.dart';

/// A single row in the Recent Transactions list.
///
/// Layout: [mode icon] | title + payment mode | amount + date·time
///
/// Phase 2.1 additions:
///   - Date label: "Today", "Yesterday", or "09 Jul 2026"
///   - Updated icons: UPI uses smartphone, Digital uses account_balance
///   - Long press → action sheet → Edit / Delete
///   - Edit: opens [AddTransactionSheet] with pre-filled fields
///   - Delete: confirmation dialog → delete from SQLite → refresh dashboard
class TransactionListItem extends ConsumerWidget {
  const TransactionListItem({super.key, required this.entry});

  final TransactionEntry entry;

  static final _timeFmt = DateFormat('h:mm a');
  static final _altDateFmt = DateFormat('d MMM yyyy');

  // ─── Date label ──────────────────────────────────────────────────────────

  String _dateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDay = DateTime(
      entry.dateTime.year,
      entry.dateTime.month,
      entry.dateTime.day,
    );

    if (txDay == today) return 'Today';
    if (txDay == yesterday) return 'Yesterday';
    return _altDateFmt.format(entry.dateTime);
  }

  // ─── Icon ─────────────────────────────────────────────────────────────────

  IconData _modeIcon() {
    switch (entry.paymentMode) {
      case PaymentMode.cash:
        return Icons.payments_rounded;
      case PaymentMode.upi:
        return Icons.smartphone_rounded;
      case PaymentMode.card:
        return Icons.credit_card_rounded;
    }
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  /// Shows the Edit / Delete action sheet when the row is long-pressed.
  ///
  /// Returns the selected action string ('edit' | 'delete') or null.
  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () => Navigator.pop(sheetCtx, 'edit'),
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.expense,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: AppColors.expense),
              ),
              onTap: () => Navigator.pop(sheetCtx, 'delete'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!context.mounted) return;

    switch (action) {
      case 'edit':
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          enableDrag: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddTransactionSheet(initialEntry: entry),
        );
      case 'delete':
        await _confirmDelete(context, ref);
    }
  }

  /// Shows a confirmation dialog then deletes the transaction.
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Delete "${entry.title}"?\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.expense,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && entry.id != null) {
      try {
        await ref
            .read(deleteTransactionProvider.notifier)
            .deleteTransaction(entry.id!);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Unable to delete transaction. Please try again.',
              ),
            ),
          );
        }
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = entry.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final prefix = isIncome ? '+' : '−';
    final dateLabel = _dateLabel();
    final timeLabel = _timeFmt.format(entry.dateTime);

    return GestureDetector(
      onLongPress: () => _showActions(context, ref),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_modeIcon(), color: color, size: 20),
        ),
        title: Text(
          entry.title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          entry.paymentMode.label,
          style: AppTextStyles.labelSmall,
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$prefix${CurrencyFormatter.format(entry.amount)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$dateLabel · $timeLabel',
              style: AppTextStyles.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
