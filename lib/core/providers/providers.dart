import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/local/database_helper.dart';

/// Provides an initialised [Database] instance to the application.
///
/// Consuming widgets should watch this provider inside a [ProviderScope].
/// The database is initialised once and reused for the application lifetime.
final databaseProvider = FutureProvider<Database>((ref) async {
  return DatabaseHelper.instance.database;
});
