import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../domain/entities/daily_summary.dart';

/// A single day cell in the monthly calendar grid.
///
/// Phase 3.1 & Phase 4:
/// - Amounts use +/− prefix (no ₹ symbol) for compact readability.
/// - Days with transactions have a bolder day number (T12).
/// - Selected/highlighted date gets a distinct border (Milestone 2).
/// - Today highlighted with a filled blue circle around day number (unchanged).
///
/// Tapping the cell calls [onTap] with the day's [DateTime].
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isCurrentMonth,
    this.summary,
    this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool isCurrentMonth;

  /// Null when no transactions exist for this day.
  final DailySummary? summary;

  final VoidCallback? onTap;

  bool get _hasTransactions => summary != null && summary!.hasTransactions;

  /// Compact amount formatter: no ₹ symbol, no decimal places.
  /// Values ≥ 1000 are abbreviated as k (e.g. 1.5k).
  static String _compact(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        isCurrentMonth ? AppColors.textPrimary : AppColors.textDisabled;

    // Active days (with transactions) get a slightly bolder day number — T12.
    final dayFontWeight = _hasTransactions && !isToday
        ? FontWeight.w700
        : (isToday ? FontWeight.w700 : FontWeight.w400);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.income.withValues(alpha: 0.12)
              : (isSelected ? AppColors.income.withValues(alpha: 0.06) : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppColors.income, width: 1.5)
              : (isToday
                  ? Border.all(color: AppColors.income.withValues(alpha: 0.4))
                  : null),
        ),
        // Fixed height avoids row-height inconsistency across weeks.
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ── Day number ──────────────────────────────────────────────
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: isToday
                  ? const BoxDecoration(
                      color: AppColors.income,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Text(
                '${date.day}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isToday ? Colors.white : textColor,
                  fontWeight: dayFontWeight,
                  fontSize: 13,
                ),
              ),
            ),

            // ── Amounts (compact, no ₹) ─────────────────────────────────
            // Reserve exactly 2 lines so all cells have the same height.
            const SizedBox(height: 2),
            SizedBox(
              height: 13,
              child: summary != null && summary!.totalIncome > 0
                  ? Text(
                      '+${_compact(summary!.totalIncome)}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.income,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    )
                  : const SizedBox.shrink(),
            ),
            SizedBox(
              height: 13,
              child: summary != null && summary!.totalExpense > 0
                  ? Text(
                      '−${_compact(summary!.totalExpense)}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.expense,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
