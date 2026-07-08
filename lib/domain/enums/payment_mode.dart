/// Represents the mode of payment used for a transaction.
///
/// Expense Notebook intentionally supports only three payment modes:
/// Cash, UPI, and Card. Bank Transfer is deliberately excluded to keep
/// the application simple.
enum PaymentMode {
  cash,
  upi,
  card;

  String get label {
    switch (this) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.upi:
        return 'UPI';
      case PaymentMode.card:
        return 'Card';
    }
  }
}
