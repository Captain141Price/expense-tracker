import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/providers.dart';
import '../../router/app_router.dart';

/// Initial Balance screen — second step of the first-launch onboarding flow.
///
/// Collects the user's opening cash and digital balances.
/// Validates input (non-empty, non-negative) before saving.
/// On success, navigates to [AppRoutes.home].
class InitialBalanceScreen extends ConsumerStatefulWidget {
  const InitialBalanceScreen({super.key});

  @override
  ConsumerState<InitialBalanceScreen> createState() =>
      _InitialBalanceScreenState();
}

class _InitialBalanceScreenState extends ConsumerState<InitialBalanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cashController = TextEditingController();
  final _digitalController = TextEditingController();

  @override
  void dispose() {
    _cashController.dispose();
    _digitalController.dispose();
    super.dispose();
  }

  // ─── Validation ──────────────────────────────────────────────────────────

  String? _validateAmount(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty.';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Enter a valid number.';
    }
    if (amount < 0) {
      return '$fieldName cannot be negative.';
    }
    return null;
  }

  // ─── Submit ──────────────────────────────────────────────────────────────

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final cash = double.parse(_cashController.text.trim());
    final digital = double.parse(_digitalController.text.trim());

    await ref.read(saveInitialBalanceProvider.notifier).saveBalances(
          initialCash: cash,
          initialDigital: digital,
        );

    // Navigate only when the save succeeded (state is AsyncData).
    final state = ref.read(saveInitialBalanceProvider);
    if (state is AsyncData && mounted) {
      context.go(AppRoutes.home);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Watch for errors from the notifier to show a snackbar.
    ref.listen(saveInitialBalanceProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Unable to save settings. Please try again.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.surface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      );
    });

    final isSaving = ref.watch(saveInitialBalanceProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          // Dismiss keyboard on tap outside.
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),

                  // ─── Icon ─────────────────────────────────────────────
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 48,
                    color: AppColors.income,
                  ),

                  const SizedBox(height: 24),

                  // ─── Heading ──────────────────────────────────────────
                  Text(
                    'Starting Balances',
                    style: AppTextStyles.headlineSmall,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Enter your current cash and digital balances.\nYou can always review this later.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ─── Cash Balance field ────────────────────────────────
                  _BalanceField(
                    controller: _cashController,
                    label: 'Cash Balance',
                    icon: Icons.payments_rounded,
                    validator: (v) => _validateAmount(v, 'Cash balance'),
                    enabled: !isSaving,
                  ),

                  const SizedBox(height: 16),

                  // ─── Digital Balance field ─────────────────────────────
                  _BalanceField(
                    controller: _digitalController,
                    label: 'Digital Balance',
                    hint: 'UPI + Card combined',
                    icon: Icons.credit_card_rounded,
                    validator: (v) => _validateAmount(v, 'Digital balance'),
                    enabled: !isSaving,
                  ),

                  const Spacer(flex: 3),

                  // ─── Continue button ───────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.income,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.income.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Continue',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Private widget ──────────────────────────────────────────────────────────

/// A single currency input field used on [InitialBalanceScreen].
///
/// Accepts only non-negative decimal numbers via a numeric keyboard.
class _BalanceField extends StatelessWidget {
  const _BalanceField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.hint,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        // Allow digits and a single decimal point only.
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      validator: validator,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint ?? '0.00',
        hintStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textDisabled,
        ),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        prefixText: '₹  ',
        prefixStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
