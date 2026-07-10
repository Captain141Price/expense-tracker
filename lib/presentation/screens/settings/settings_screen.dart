import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/providers.dart';
import '../../../domain/services/database_service.dart';
import '../../router/app_router.dart';


/// Settings screen for managing backups, exports, database state, and viewing diagnostics.
///
/// Phase 4 — Milestones 4–8.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Triggers full invalidation of state providers to reload database content.
  void _invalidateAllProviders(WidgetRef ref) {
    ref.invalidate(appSettingsProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(recentTransactionsProvider);
    ref.invalidate(monthSummariesProvider);
    ref.invalidate(dailyLedgerProvider);
    ref.invalidate(databaseStatsProvider);
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> _exportCSV(BuildContext context, WidgetRef ref) async {
    try {
      final repo = await ref.read(transactionRepositoryProvider.future);
      final txs = await repo.getAllTransactions();

      if (txs.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No transactions to export.')),
          );
        }
        return;
      }

      final success = await DatabaseService.exportCSV(txs);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV file shared successfully.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export CSV.')),
        );
      }
    }
  }

  Future<void> _exportPDF(BuildContext context, WidgetRef ref) async {
    try {
      final repo = await ref.read(transactionRepositoryProvider.future);
      final txs = await repo.getAllTransactions();
      final settings = await ref.read(appSettingsProvider.future);

      if (txs.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No transactions to export.')),
          );
        }
        return;
      }

      final initialCash = settings?.initialCash ?? 0.0;
      final initialDigital = settings?.initialDigital ?? 0.0;

      final success = await DatabaseService.exportPDF(
        txs,
        initialCash: initialCash,
        initialDigital: initialDigital,
      );
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF Ledger shared successfully.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export PDF.')),
        );
      }
    }
  }

  Future<void> _backupDb(BuildContext context, WidgetRef ref) async {
    try {
      final db = await ref.read(databaseProvider.future);
      final destPath = await DatabaseService.backupDatabase(db.path);

      if (destPath != null && context.mounted) {
        ref.invalidate(databaseStatsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup saved: ...${p.basename(destPath)}')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database backup failed.')),
        );
      }
    }
  }

  Future<void> _restoreDb(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Restore Database'),
        content: const Text(
          'WARNING: This will overwrite your current transactions and configuration.\n\nThis cannot be undone. Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final db = await ref.read(databaseProvider.future);
      final success = await DatabaseService.restoreDatabase(db.path);

      if (success && context.mounted) {
        _invalidateAllProviders(ref);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database restored successfully.')),
        );
        // Force splash redirection to reinitialize and route correctly.
        context.go(AppRoutes.splash);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to restore database.')),
        );
      }
    }
  }

  Future<void> _deleteAllData(BuildContext context, WidgetRef ref) async {
    final textController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete All Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WARNING: This will permanently wipe all transactions, settings, and initial balances.\n\nType DELETE below to confirm:',
              style: TextStyle(height: 1.3),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'DELETE',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.trim() == 'DELETE') {
                Navigator.pop(dialogCtx, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Word does not match. Action aborted.')),
                );
                Navigator.pop(dialogCtx, false);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    textController.dispose();
    if (confirmed != true) return;

    try {
      final repo = await ref.read(transactionRepositoryProvider.future);
      await repo.deleteAllData();

      if (context.mounted) {
        _invalidateAllProviders(ref);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data deleted.')),
        );
        // Force onboarding setup restart.
        context.go(AppRoutes.splash);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wipe operation failed.')),
        );
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(databaseStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: statsAsync.when(
        data: (stats) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // ── DATA SECTION ────────────────────────────────────────────────
            _buildSectionHeader('Data Management'),
            _buildActionTile(
              icon: Icons.upload_file_rounded,
              title: 'Export as CSV',
              subtitle: 'Share comma-separated sheet of ledger',
              onTap: () => _exportCSV(context, ref),
            ),
            _buildActionTile(
              icon: Icons.picture_as_pdf_rounded,
              title: 'Export as PDF',
              subtitle: 'Share printable document with running balance',
              onTap: () => _exportPDF(context, ref),
            ),
            _buildActionTile(
              icon: Icons.backup_rounded,
              title: 'Backup Database',
              subtitle: 'Copy SQLite file to user-selected folder',
              onTap: () => _backupDb(context, ref),
            ),
            _buildActionTile(
              icon: Icons.settings_backup_restore_rounded,
              title: 'Restore Database',
              subtitle: 'Load previously exported database backup',
              onTap: () => _restoreDb(context, ref),
            ),
            _buildActionTile(
              icon: Icons.delete_forever_rounded,
              title: 'Delete All Data',
              subtitle: 'Wipe all database records and start over',
              isDestructive: true,
              onTap: () => _deleteAllData(context, ref),
            ),

            const Divider(height: 32),

            // ── DATABASE HEALTH SECTION ─────────────────────────────────────
            _buildSectionHeader('Database Health'),
            _buildReadonlyTile('Database Size', stats.formattedSize),
            _buildReadonlyTile('Total Transactions', stats.totalTransactions.toString()),
            _buildReadonlyTile('Last Backup', stats.lastBackup),
            _buildReadonlyTile('SQLite Version', stats.sqliteVersion),
            _buildReadonlyTile('Storage Location', stats.storageLocation, isLongPath: true),

            const Divider(height: 32),

            // ── APPLICATION / ABOUT SECTION ─────────────────────────────────
            _buildSectionHeader('Application'),
            _buildReadonlyTile('App Version', '0.4.1+1'),
            _buildReadonlyTile('Sync Type', 'Offline-First Notebook'),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Text(
                'Expense Notebook does not run cloud sync, keeping all tracking private on your local storage.',
                style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Error loading settings.')),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.income,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.expense : AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.expense : AppColors.income),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.labelSmall.copyWith(fontSize: 11),
      ),
      onTap: onTap,
    );
  }

  Widget _buildReadonlyTile(String label, String value, {bool isLongPath = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
              maxLines: isLongPath ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

