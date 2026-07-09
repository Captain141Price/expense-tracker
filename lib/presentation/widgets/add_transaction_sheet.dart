import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/providers.dart';
import '../../domain/entities/transaction_entry.dart';
import '../../domain/enums/payment_mode.dart';
import '../../domain/enums/transaction_type.dart';

/// Material 3 bottom sheet for adding OR editing a transaction.
///
/// **Add mode** (`initialEntry == null`):
///   - Type defaults to [TransactionType.expense] (most common action).
///   - Payment mode defaults to the last-used mode for this session.
///   - Title field auto-focuses; keyboard opens immediately.
///   - On success: SnackBar "Transaction saved" + sheet dismissed.
///
/// **Edit mode** (`initialEntry != null`):
///   - All fields pre-filled from [initialEntry].
///   - On success: SnackBar "Transaction updated" + sheet dismissed.
///
/// Both modes invalidate [dashboardSummaryProvider] and
/// [recentTransactionsProvider] for an instant Dashboard refresh.
class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key, this.initialEntry});

  /// When non-null the sheet operates in edit mode.
  final TransactionEntry? initialEntry;

  bool get isEditing => initialEntry != null;

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  late TransactionType _selectedType;
  late PaymentMode _selectedMode;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  var _isSaving = false;

  static final _displayDateFmt = DateFormat('d MMM yyyy');

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final entry = widget.initialEntry;
    if (entry != null) {
      // ── Edit mode: pre-fill all fields from existing entry ──────────────
      _titleController.text = entry.title;
      // Show integer amounts without trailing ".0"; decimals with 2dp
      _amountController.text = entry.amount == entry.amount.truncateToDouble()
          ? entry.amount.toInt().toString()
          : entry.amount.toStringAsFixed(2);
      _selectedType = entry.type;
      _selectedMode = entry.paymentMode;
      _selectedDate = entry.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(entry.dateTime);
    } else {
      // ── Add mode ─────────────────────────────────────────────────────────
      final now = DateTime.now();
      // Task 1: default to Expense (most frequent action in an expense tracker)
      _selectedType = TransactionType.expense;
      // Task 2: restore last-used payment mode for this session
      _selectedMode = ref.read(lastPaymentModeProvider);
      _selectedDate = now;
      _selectedTime = TimeOfDay.fromDateTime(now);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ─── Pickers ─────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  // ─── Save / Update ────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final now = DateTime.now();
    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    setState(() => _isSaving = true);
    try {
      if (widget.isEditing) {
        // ── Edit: update existing entry ─────────────────────────────────
        final updated = widget.initialEntry!.copyWith(
          title: _titleController.text.trim(),
          amount: amount,
          type: _selectedType,
          paymentMode: _selectedMode,
          dateTime: combinedDateTime,
          isEdited: true,
          updatedAt: now,
        );
        await ref
            .read(editTransactionProvider.notifier)
            .updateTransaction(updated);
      } else {
        // ── Add: create new entry ───────────────────────────────────────
        final entry = TransactionEntry(
          title: _titleController.text.trim(),
          amount: amount,
          type: _selectedType,
          paymentMode: _selectedMode,
          dateTime: combinedDateTime,
          createdAt: now,
          updatedAt: now,
        );
        await ref.read(addTransactionProvider.notifier).addTransaction(entry);
      }

      // Task 2: persist last-used payment mode for the session
      ref.read(lastPaymentModeProvider.notifier).state = _selectedMode;

      if (mounted) {
        // Task 6: show success SnackBar before dismissing
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing ? 'Transaction updated' : 'Transaction saved',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Unable to update transaction. Please try again.'
                  : 'Unable to save transaction. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final sheetTitle =
        widget.isEditing ? 'Edit Transaction' : 'Add Transaction';
    final saveLabel = widget.isEditing ? 'Update' : 'Save';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: keyboardInset + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drag handle ──────────────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Sheet title ──────────────────────────────────────────────
              Text(sheetTitle, style: AppTextStyles.titleMedium),
              const SizedBox(height: 20),

              // ── Income / Expense toggle ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Income'),
                      icon: Icon(Icons.arrow_upward_rounded),
                    ),
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Expense'),
                      icon: Icon(Icons.arrow_downward_rounded),
                    ),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (s) =>
                      setState(() => _selectedType = s.first),
                ),
              ),
              const SizedBox(height: 16),

              // ── Title field (Task 3: autofocus) ──────────────────────────
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                textCapitalization: TextCapitalization.sentences,
                autofocus: true, // Task 3: keyboard opens immediately
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Title is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Amount field ─────────────────────────────────────────────
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Amount is required.';
                  }
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null) return 'Enter a valid number.';
                  if (parsed <= 0) return 'Amount must be greater than 0.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Payment Mode ─────────────────────────────────────────────
              Text(
                'Payment Mode',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<PaymentMode>(
                  segments: const [
                    ButtonSegment(
                      value: PaymentMode.cash,
                      label: Text('Cash'),
                      icon: Icon(Icons.payments_rounded),
                    ),
                    ButtonSegment(
                      value: PaymentMode.upi,
                      label: Text('UPI'),
                      icon: Icon(Icons.smartphone_rounded),
                    ),
                    ButtonSegment(
                      value: PaymentMode.card,
                      label: Text('Card'),
                      icon: Icon(Icons.credit_card_rounded),
                    ),
                  ],
                  selected: {_selectedMode},
                  onSelectionChanged: (s) =>
                      setState(() => _selectedMode = s.first),
                ),
              ),
              const SizedBox(height: 16),

              // ── Date and Time row ────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: _buildDateTile()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimeTile()),
                ],
              ),
              const SizedBox(height: 24),

              // ── Save / Update button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(saveLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helper widgets ───────────────────────────────────────────────────────

  Widget _buildDateTile() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    _displayDateFmt.format(_selectedDate),
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTile() {
    final hour = _selectedTime.hour.toString().padLeft(2, '0');
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Time', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 2),
                  Text(timeStr, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            const Icon(
              Icons.access_time_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
