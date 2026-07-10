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

  /// Returns a compact rupee string suitable for narrow spaces (e.g. calendar cells).
  ///
  /// Examples:
  /// - `formatCompact(500)`        → `"₹500"`
  /// - `formatCompact(1500)`       → `"₹1.5k"`
  /// - `formatCompact(100000)`     → `"₹1.0L"`
  /// - `formatCompact(10000000)`   → `"₹1.0Cr"`
  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}k';
    }
    // For amounts < 1000, show no decimal places to save space.
    return '₹${amount.toInt()}';
  }
}
