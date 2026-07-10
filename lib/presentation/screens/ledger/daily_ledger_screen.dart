import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/providers.dart';
import '../../../domain/entities/daily_ledger.dart';
import '../../../domain/entities/transaction_entry.dart';
import 'widgets/ledger_balance_tile.dart';
import 'widgets/ledger_date_header.dart';
import 'widgets/ledger_summary_card.dart';
import 'widgets/ledger_transaction_item.dart';

/// Daily Ledger screen — Phase 3 / Phase 3.1 polish.
///
/// Shows a complete daily view for [date]:
///   Date header (weekday + full date)
///   Opening Balance      ← calculated, never stored
///   Transactions         ← newest first; empty state if none (T8)
///   Daily Summary        ← income / expense / net / count
///   Closing Balance      ← calculated, never stored
///
/// T5: All cards use identical padding (all:16), margin:zero, same radius.
/// T8: Empty day still renders Opening Balance and Closing Balance correctly.
/// T13/T14: SingleChildScrollView with safe horizontal padding; large tap targets.
///
/// Opened from [CalendarScreen] via a push navigation.
/// Ledger data is prefetched by [CalendarScreen._onDayTap] for instant display.
class DailyLedgerScreen extends ConsumerWidget {
  const DailyLedgerScreen({super.key, required this.date});

  /// The calendar date for which to display the ledger.
  /// Normalised to midnight by the router; time component is ignored.
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerAsync = ref.watch(dailyLedgerProvider(date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Ledger'),
        // Back button auto-provided by go_router push navigation.
      ),
      body: ledgerAsync.when(
        skipLoadingOnReload: true,
        data: (ledger) => _LedgerContent(ledger: ledger),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Unable to load ledger.\nPlease go back and try again.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Content ──────────────────────────────────────────────────────────────────

class _LedgerContent extends StatelessWidget {
  const _LedgerContent({required this.ledger});

  final DailyLedger ledger;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // T13: AlwaysScrollableScrollPhysics prevents layout issues on large screens.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Date ──────────────────────────────────────────────────────
          LedgerDateHeader(date: ledger.date),
          const SizedBox(height: 20),

          // ── Opening Balance ───────────────────────────────────────────
          LedgerBalanceTile(
            label: 'Opening Balance',
            amount: ledger.openingBalance,
          ),
          const SizedBox(height: 12),

          // ── Transactions ──────────────────────────────────────────────
          // T8: Always rendered — shows "No transactions recorded." when empty,
          // but Opening Balance and Closing Balance are still correctly displayed.
          _TransactionSection(transactions: ledger.transactions),
          const SizedBox(height: 12),

          // ── Daily Summary ─────────────────────────────────────────────
          LedgerSummaryCard(
            totalIncome: ledger.totalIncome,
            totalExpense: ledger.totalExpense,
            transactionCount: ledger.transactionCount,
          ),
          const SizedBox(height: 12),

          // ── Closing Balance ───────────────────────────────────────────
          LedgerBalanceTile(
            label: 'Closing Balance',
            amount: ledger.closingBalance,
            isClosing: true,
          ),
        ],
      ),
    );
  }
}

// ─── Transactions Section ─────────────────────────────────────────────────────

class _TransactionSection extends StatelessWidget {
  const _TransactionSection({required this.transactions});

  final List<TransactionEntry> transactions;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // T5: parent Column manages spacing
      child: Padding(
        padding: const EdgeInsets.all(16), // T5: identical to other cards
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transactions',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),

            // T8: Empty state — shown when no transactions, balances still correct.
            if (transactions.isEmpty) ...[
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 36,
                      color: AppColors.textDisabled,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No transactions recorded.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              // T13: No wrapping, each item ellipsizes gracefully (T10).
              ...List.generate(transactions.length, (i) {
                final entry = transactions[i];
                final isLast = i == transactions.length - 1;
                return Column(
                  children: [
                    LedgerTransactionItem(entry: entry),
                    if (!isLast) const Divider(height: 1),
                  ],
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
