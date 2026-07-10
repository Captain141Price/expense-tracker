/// Model representing database health and statistics.
class DatabaseHealthInfo {
  const DatabaseHealthInfo({
    required this.sizeBytes,
    required this.totalTransactions,
    required this.lastBackup,
    required this.sqliteVersion,
    required this.storageLocation,
  });

  final int sizeBytes;
  final int totalTransactions;
  final String lastBackup;
  final String sqliteVersion;
  final String storageLocation;

  /// Helper to get database size in formatted string.
  String get formattedSize {
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (sizeBytes >= 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(2)} KB';
    }
    return '$sizeBytes Bytes';
  }
}
