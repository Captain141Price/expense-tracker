import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../data/local/database_helper.dart';
import '../entities/transaction_entry.dart';
import '../enums/transaction_type.dart';

/// Service responsible for file-based operations: imports, exports, and backup/restore.
abstract final class DatabaseService {
  /// Exports all transactions to CSV format and opens the native share sheet.
  static Future<bool> exportCSV(List<TransactionEntry> transactions) async {
    try {
      final csvBuffer = StringBuffer();
      // CSV headers
      csvBuffer.writeln('Date,Time,Title,Type,Payment Mode,Amount');

      final dateFmt = DateFormat('yyyy-MM-dd');
      final timeFmt = DateFormat('HH:mm');

      for (final tx in transactions) {
        final dateStr = dateFmt.format(tx.dateTime);
        final timeStr = timeFmt.format(tx.dateTime);
        final escapedTitle = tx.title.replaceAll('"', '""');
        csvBuffer.writeln(
          '$dateStr,$timeStr,"$escapedTitle",${tx.type.name},${tx.paymentMode.label},${tx.amount}',
        );
      }

      final tempDir = await getTemporaryDirectory();
      final file = File(p.join(tempDir.path, 'expense_notebook_export.csv'));
      await file.writeAsString(csvBuffer.toString());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Expense Notebook CSV Export',
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Exports all transactions to PDF format with a calculated running balance.
  ///
  /// The running balance starts from [initialCash] + [initialDigital] and computes
  /// chronologically (oldest first).
  static Future<bool> exportPDF(
    List<TransactionEntry> transactions, {
    required double initialCash,
    required double initialDigital,
  }) async {
    try {
      // PDF package requires chronological order for running balance
      final chronologicalTxs = List<TransactionEntry>.from(transactions).reversed.toList();

      final pdf = pw.Document();
      final dateFmt = DateFormat('yyyy-MM-dd');
      final timeFmt = DateFormat('hh:mm a');
      final curFmt = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 2);

      double balance = initialCash + initialDigital;

      final List<List<String>> tableData = [];
      tableData.add([
        'Date',
        'Time',
        'Title',
        'Mode',
        'Income',
        'Expense',
        'Running Bal.',
      ]);

      for (final tx in chronologicalTxs) {
        final isIncome = tx.type == TransactionType.income;
        if (isIncome) {
          balance += tx.amount;
        } else {
          balance -= tx.amount;
        }

        tableData.add([
          dateFmt.format(tx.dateTime),
          timeFmt.format(tx.dateTime),
          tx.title,
          tx.paymentMode.label,
          isIncome ? curFmt.format(tx.amount) : '-',
          !isIncome ? curFmt.format(tx.amount) : '-',
          curFmt.format(balance),
        ]);
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Expense Notebook Ledger',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      DateFormat('d MMM yyyy').format(DateTime.now()),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Initial Setup Balance: ${curFmt.format(initialCash + initialDigital)} (Cash: ${curFmt.format(initialCash)} | Digital: ${curFmt.format(initialDigital)})',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headers: tableData[0],
                data: tableData.sublist(1),
                border: const pw.TableBorder(
                  horizontalInside: pw.BorderSide(width: 0.5, color: PdfColors.grey300),
                  bottom: pw.BorderSide(width: 1, color: PdfColors.grey400),
                  top: pw.BorderSide(width: 1, color: PdfColors.grey400),
                ),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                cellStyle: const pw.TextStyle(fontSize: 7),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                  4: pw.Alignment.centerRight,
                  5: pw.Alignment.centerRight,
                  6: pw.Alignment.centerRight,
                },
              ),
            ];
          },
        ),
      );

      final tempDir = await getTemporaryDirectory();
      final file = File(p.join(tempDir.path, 'expense_notebook_ledger.pdf'));
      await file.writeAsBytes(await pdf.save());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Expense Notebook PDF Ledger Export',
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Copies the database file to a user-selected folder.
  /// Returns the destination path string if successful, or null.
  static Future<String?> backupDatabase(String dbPath) async {
    try {
      final selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) return null;

      final dbFile = File(dbPath);
      final destPath = p.join(selectedDirectory, 'expense_tracker_backup.db');

      // Safe copy
      await dbFile.copy(destPath);

      // Write metadata file in db folder
      final metaFile = File(p.join(p.dirname(dbPath), 'backup_metadata.txt'));
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      await metaFile.writeAsString(dateStr);

      return destPath;
    } catch (_) {
      return null;
    }
  }

  /// Safely replaces the current SQLite file with a chosen backup file.
  static Future<bool> restoreDatabase(String dbPath) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.single.path == null) {
        return false;
      }

      final backupFile = File(result.files.single.path!);

      // Close open database first to release file locks
      await DatabaseHelper.instance.closeDatabase();

      // Overwrite db file
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
      await backupFile.copy(dbPath);

      return true;
    } catch (_) {
      return false;
    }
  }
}
