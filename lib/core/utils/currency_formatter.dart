import 'package:intl/intl.dart';

/// Formats monetary values in Indian Rupee (₹) notation.
///
/// Uses the `en_IN` locale for Indian number grouping,
/// e.g. `₹1,23,456.00`.
abstract final class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Returns a formatted rupee string.
  ///
  /// Examples:
  /// - `format(1234.5)` → `"₹1,234.50"`
  /// - `format(0)`       → `"₹0.00"`
  static String format(double amount) => _formatter.format(amount);
}
