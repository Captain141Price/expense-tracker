import '../enums/payment_mode.dart';
import '../enums/transaction_type.dart';

/// Domain entity representing a single row in the [transactions] table.
///
/// Design notes:
///
/// - [dateTime] unifies the separate `date` (yyyy-MM-dd) and `time` (HH:mm)
///   database columns into a single ergonomic [DateTime] for domain/UI use.
///   The data layer handles conversion in both directions.
///
/// - [isEdited] is reserved for Phase 5 (Edit/Delete support). It is always
///   `false` in Phase 2 and is not yet persisted to the database. A migration
///   will add the column when Phase 5 is implemented.
///
/// - Named [TransactionEntry] (not `Transaction`) to avoid a naming collision
///   with Flutter's built-in [Transaction] type from the services layer.
class TransactionEntry {
  const TransactionEntry({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.paymentMode,
    required this.dateTime,
    this.isEdited = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Auto-generated row id. Null for entries that have not been persisted yet.
  final int? id;

  final String title;

  /// Always positive. Type (income / expense) determines the sign semantics.
  final double amount;

  final TransactionType type;

  final PaymentMode paymentMode;

  /// The user-specified date and time of the transaction.
  ///
  /// Stored in SQLite as two separate TEXT columns (`date`, `time`).
  /// Reconstructed from those columns on read.
  final DateTime dateTime;

  /// Whether this entry has been edited after its initial creation.
  ///
  /// Always `false` in Phase 2. Phase 5 will add the `isEdited` SQLite column
  /// and surface edit history in the UI.
  final bool isEdited;

  /// Wall-clock time at which this row was inserted into the database.
  final DateTime createdAt;

  /// Wall-clock time at which this row was last updated.
  final DateTime updatedAt;

  TransactionEntry copyWith({
    int? id,
    String? title,
    double? amount,
    TransactionType? type,
    PaymentMode? paymentMode,
    DateTime? dateTime,
    bool? isEdited,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      paymentMode: paymentMode ?? this.paymentMode,
      dateTime: dateTime ?? this.dateTime,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'TransactionEntry('
      'id: $id, '
      'title: $title, '
      'amount: $amount, '
      'type: ${type.name}, '
      'paymentMode: ${paymentMode.name}, '
      'dateTime: $dateTime, '
      'isEdited: $isEdited)';
}
