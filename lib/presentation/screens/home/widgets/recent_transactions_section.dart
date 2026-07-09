import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/entities/transaction_entry.dart';
import 'transaction_list_item.dart';

/// Shows the "Recent Transactions" section header followed by either:
///
/// - A card containing up to [AppConstants.recentTransactionsLimit] rows, or
/// - An empty-state message ("No transactions yet.") if the list is empty.
class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({
    super.key,
    required this.transactionsAsync,
  });

  final AsyncValue<List<TransactionEntry>> transactionsAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Transactions', style: AppTextStyles.titleSmall),
        const SizedBox(height: 12),
        transactionsAsync.when(
          data: (transactions) => transactions.isEmpty
              ? const _EmptyTransactions()
              : Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: transactions.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) =>
                        TransactionListItem(entry: transactions[index]),
                  ),
                ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Unable to load transactions.',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}

/// Empty state displayed when there are no transactions.
class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Center(
          child: Text(
            'No transactions yet.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
