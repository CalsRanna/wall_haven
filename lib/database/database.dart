import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:laconic/laconic.dart';
import '../util/logger_util.dart';
import 'migration/migration_001.dart';

class Database {
  static final Database _instance = Database._internal();
  static Database get instance => _instance;

  late Laconic laconic;
  late String path;

  Database._internal();

  Future<void> ensureInitialized() async {
    final directory = await getApplicationSupportDirectory();
    path = '${directory.path}/wall_haven.db';

    final file = File(path);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }

    final config = SqliteConfig(path);
    laconic = Laconic.sqlite(config, listen: (query) {
      LoggerUtil.instance.d('SQL: ${query.sql}');
    });

    await _migrate();
    LoggerUtil.instance.i('Database initialized at: $path');
  }

  Future<void> _migrate() async {
    // Create migrations table
    await laconic.statement('''
      CREATE TABLE IF NOT EXISTS migrations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        created_at INTEGER DEFAULT (strftime('%s', 'now'))
      )
    ''');

    // Execute migrations
    await Migration001().migrate(laconic);
  }
}
