import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Date header for the Daily Ledger screen.
///
/// Displays:
///   Thursday        ← weekday name (large)
///   9 July 2026     ← full date (secondary)
class LedgerDateHeader extends StatelessWidget {
  const LedgerDateHeader({super.key, required this.date});

  final DateTime date;

  static final _weekdayFmt = DateFormat('EEEE');
  static final _dateFmt = DateFormat('d MMMM yyyy');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _weekdayFmt.format(date),
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _dateFmt.format(date),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
