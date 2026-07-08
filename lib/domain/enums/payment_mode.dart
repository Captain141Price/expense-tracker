/// Represents the mode of payment used for a transaction.
enum PaymentMode {
  cash,
  card,
  upi,
  bankTransfer;

  String get label {
    switch (this) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.card:
        return 'Card';
      case PaymentMode.upi:
        return 'UPI';
      case PaymentMode.bankTransfer:
        return 'Bank Transfer';
    }
  }
}
