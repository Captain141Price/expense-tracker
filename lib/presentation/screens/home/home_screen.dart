import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/add_transaction_sheet.dart';
import 'widgets/balance_card.dart';
import 'widgets/balance_row.dart';
import 'widgets/recent_transactions_section.dart';
import 'widgets/today_summary_card.dart';
import 'package:go_router/go_router.dart';

/// Dashboard screen — Phase 2 / Phase 2.1.
///
/// Displays all balance cards, today's summary, and recent transactions.
/// AppBar shows today's date below the app name.
/// FAB opens the Add Transaction sheet.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static final _dayFmt = DateFormat('EEEE');
  static final _dateFmt = DateFormat('d MMMM yyyy');

  void _openAddTransaction(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final transactionsAsync = ref.watch(recentTransactionsProvider);

    final now = DateTime.now();
    final dayName = _dayFmt.format(now);
    final dateStr = _dateFmt.format(now);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Expense Notebook', style: AppTextStyles.titleLarge),
            const SizedBox(height: 2),
            Text(
              dayName,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              dateStr,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(recentTransactionsProvider);
          await Future.wait([
            ref.read(dashboardSummaryProvider.future),
            ref.read(recentTransactionsProvider.future),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Total Balance ──────────────────────────────────────────
              BalanceCard(summaryAsync: summaryAsync),
              const SizedBox(height: 16),

              // ── Cash Balance  |  Digital Balance ──────────────────────
              BalanceRow(summaryAsync: summaryAsync),
              const SizedBox(height: 24),

              // ── Today's Income / Expense / Net ─────────────────────────
              TodaySummaryCard(summaryAsync: summaryAsync),
              const SizedBox(height: 24),

              // ── Recent Transactions ────────────────────────────────────
              RecentTransactionsSection(transactionsAsync: transactionsAsync),
            ],
          ),
        ),
      ),

      // ── FAB — blue, bottom-right ───────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTransaction(context),
        backgroundColor: AppColors.income,
        foregroundColor: Colors.white,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ── Bottom Navigation ─────────────────────────────────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) context.go(AppRoutes.calendar);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}
