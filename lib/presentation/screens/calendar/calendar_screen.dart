import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/providers.dart';
import '../../../domain/entities/daily_summary.dart';
import '../../../domain/services/ledger_service.dart';
import '../../router/app_router.dart';
import 'widgets/calendar_day_cell.dart';
import 'widgets/calendar_header.dart';

/// Material 3 monthly calendar screen.
///
/// Phase 3 / Phase 3.1 / Phase 4.
///
/// Features:
/// - Navigate previous / next month with AnimatedSwitcher (T6 — no flicker).
/// - Today highlighted with a filled blue indicator.
/// - Jump to Date icon in AppBar opens Material Date Picker (Milestone 2).
/// - Today button in header returns to current month and selects current day (Milestone 3).
/// - Selected/jumped-to date is highlighted in the grid.
/// - Each day cell shows +income / −expense compact amounts from SQLite.
/// - Monthly income/expense totals below the header.
/// - Empty month state: grid stays visible with "No transactions this month.".
/// - Active days (with transactions) have a bolder day number.
/// - Tapping a day prefetches the ledger and navigates to the Daily Ledger screen.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  /// Weekday header labels (Mon–Sun).
  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  Future<void> _selectJumpDate(BuildContext context, WidgetRef ref) async {
    final selectedDate = ref.read(calendarSelectedDateProvider) ?? DateTime.now();


    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.income,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final normalizedPicked = DateTime(picked.year, picked.month, picked.day);
      // Update selected date highlight
      ref.read(calendarSelectedDateProvider.notifier).state = normalizedPicked;
      // Jump month view
      ref.read(calendarMonthProvider.notifier).state = DateTime(picked.year, picked.month, 1);
    }
  }

  void _goToToday(WidgetRef ref) {
    final now = DateTime.now();
    final todayNorm = DateTime(now.year, now.month, now.day);
    // Select today
    ref.read(calendarSelectedDateProvider.notifier).state = todayNorm;
    // Jump to current month
    ref.read(calendarMonthProvider.notifier).state = DateTime(now.year, now.month, 1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(calendarMonthProvider);
    final summariesAsync = ref.watch(monthSummariesProvider);
    final selectedDate = ref.watch(calendarSelectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            onPressed: () => _selectJumpDate(context, ref),
            tooltip: 'Jump to Date',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Month navigation header ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CalendarHeader(
              month: month,
              onPreviousMonth: () {
                ref.read(calendarMonthProvider.notifier).state =
                    DateTime(month.year, month.month - 1, 1);
              },
              onNextMonth: () {
                ref.read(calendarMonthProvider.notifier).state =
                    DateTime(month.year, month.month + 1, 1);
              },
              onToday: () => _goToToday(ref),
            ),
          ),

          // ── Monthly totals row — derived from summaries, zero extra SQL ──
          summariesAsync.when(
            skipLoadingOnReload: true,
            data: (summaries) {
              final totals =
                  LedgerService.monthTotalsFromSummaries(summaries);
              return _MonthlyTotalsRow(
                income: totals.income,
                expense: totals.expense,
              );
            },
            loading: () => const _MonthlyTotalsRow(income: 0, expense: 0),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const Divider(height: 1),

          // ── Weekday headers ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Row(
              children: _weekdays
                  .map(
                    (d) => Expanded(
                      child: Text(
                        d,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          // ── Calendar grid with AnimatedSwitcher ──────────────────────
          Expanded(
            child: summariesAsync.when(
              skipLoadingOnReload: true,
              data: (summaries) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: _CalendarGrid(
                  key: ValueKey('${month.year}-${month.month}'),
                  month: month,
                  summaries: summaries,
                  selectedDate: selectedDate,
                  onDayTap: (date) => _onDayTap(context, ref, date),
                ),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Unable to load calendar.\nPlease try again.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Navigation ──────────────────────────────────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) context.go(AppRoutes.home);
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

  /// Prefetches the ledger for [date] then navigates.
  void _onDayTap(BuildContext context, WidgetRef ref, DateTime date) {
    final normalised = DateTime(date.year, date.month, date.day);
    // Select this day when tapped directly (helps tracking)
    ref.read(calendarSelectedDateProvider.notifier).state = normalised;
    // Kick off prefetch
    ref.read(dailyLedgerProvider(normalised).future).ignore();
    // Navigate with the horizontal slide page transition
    context.push(AppRoutes.ledgerPath(normalised));
  }
}

// ─── Monthly Totals Row ───────────────────────────────────────────────────────

class _MonthlyTotalsRow extends StatelessWidget {
  const _MonthlyTotalsRow({required this.income, required this.expense});

  final double income;
  final double expense;

  static String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          // Income
          if (income > 0) ...[
            Icon(Icons.arrow_upward_rounded,
                size: 12, color: AppColors.income),
            const SizedBox(width: 3),
            Text(
              '+${_fmt(income)}',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.income,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 16),
          ],
          // Expense
          if (expense > 0) ...[
            Icon(Icons.arrow_downward_rounded,
                size: 12, color: AppColors.expense),
            const SizedBox(width: 3),
            Text(
              '−${_fmt(expense)}',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.expense,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          // No transactions this month
          if (income == 0 && expense == 0)
            Text(
              'No transactions this month.',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textDisabled,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Calendar Grid ────────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    super.key,
    required this.month,
    required this.summaries,
    required this.selectedDate,
    required this.onDayTap,
  });

  final DateTime month;
  final Map<String, DailySummary> summaries;
  final DateTime? selectedDate;
  final void Function(DateTime) onDayTap;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    // Find the Monday that starts the calendar grid.
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    // weekday: Mon=1, Sun=7. Offset 0 for Monday.
    final startOffset = (firstDayOfMonth.weekday - 1) % 7;

    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final totalCells = startOffset + lastDayOfMonth.day;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: List.generate(rows, (row) {
          return Expanded(
            child: Row(
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayNumber = cellIndex - startOffset + 1;

                if (dayNumber < 1 || dayNumber > lastDayOfMonth.day) {
                  // Empty padding cell — outside current month.
                  return const Expanded(child: SizedBox());
                }

                final cellDate =
                    DateTime(month.year, month.month, dayNumber);
                final isToday = cellDate == todayNorm;
                final isSelected = selectedDate != null && cellDate == selectedDate;
                final dateKey =
                    '${cellDate.year.toString().padLeft(4, '0')}-'
                    '${cellDate.month.toString().padLeft(2, '0')}-'
                    '${cellDate.day.toString().padLeft(2, '0')}';

                return Expanded(
                  child: CalendarDayCell(
                    date: cellDate,
                    isToday: isToday,
                    isSelected: isSelected,
                    isCurrentMonth: true,
                    summary: summaries[dateKey],
                    onTap: () => onDayTap(cellDate),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
