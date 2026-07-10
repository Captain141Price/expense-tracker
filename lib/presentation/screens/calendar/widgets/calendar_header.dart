import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

/// Month navigation header for the calendar grid.
///
/// Displays the current month name + year with left/right arrows to
/// navigate to the previous or next month, and a "Today" shortcut button.
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.month,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
  });

  /// The first day of the currently displayed month.
  final DateTime month;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;

  static final _monthFmt = DateFormat('MMMM yyyy');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Previous month ─────────────────────────────────────────────
        IconButton(
          onPressed: onPreviousMonth,
          icon: const Icon(Icons.chevron_left_rounded),
          color: AppColors.textSecondary,
          tooltip: 'Previous month',
        ),

        // ── Today button shortcut (Milestone 3) ────────────────────────
        TextButton(
          onPressed: onToday,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Today',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.income,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ── Month / Year label ─────────────────────────────────────────
        Expanded(
          child: Text(
            _monthFmt.format(month),
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // ── Next month ─────────────────────────────────────────────────
        IconButton(
          onPressed: onNextMonth,
          icon: const Icon(Icons.chevron_right_rounded),
          color: AppColors.textSecondary,
          tooltip: 'Next month',
        ),
      ],
    );
  }
}
