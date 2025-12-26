import 'package:laconic/laconic.dart';

class Migration001 {
  static const name = 'migration_001';

  Future<void> migrate(Laconic laconic) async {
    final result = await laconic.table('migrations').where('name', name).get();
    if (result.isNotEmpty) return;

    // Create favorites table
    await laconic.statement('''
      CREATE TABLE IF NOT EXISTS favorites (
        id TEXT PRIMARY KEY,
        wallpaper_id TEXT NOT NULL UNIQUE,
        thumbnail_url TEXT NOT NULL,
        original_url TEXT NOT NULL,
        resolution TEXT NOT NULL,
        category TEXT,
        purity TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create downloads history table
    await laconic.statement('''
      CREATE TABLE IF NOT EXISTS downloads (
        id TEXT PRIMARY KEY,
        wallpaper_id TEXT NOT NULL,
        file_path TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create indexes
    await laconic.statement('''
      CREATE INDEX IF NOT EXISTS idx_favorites_created_at
      ON favorites(created_at DESC)
    ''');

    await laconic.statement('''
      CREATE INDEX IF NOT EXISTS idx_downloads_created_at
      ON downloads(created_at DESC)
    ''');

    // Record migration
    await laconic.table('migrations').insert([
      {'name': name},
    ]);
  }
}
