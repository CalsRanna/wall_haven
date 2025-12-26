import '../database/database.dart';
import '../model/favorite_entity.dart';

class FavoriteRepository {
  final Database _database;

  FavoriteRepository(this._database);

  Future<List<FavoriteEntity>> getAll() async {
    final results = await _database.laconic
        .table('favorites')
        .orderBy('created_at', direction: 'desc')
        .get();

    return results.map((r) => FavoriteEntity.fromJson(r.toMap())).toList();
  }

  Future<FavoriteEntity?> getByWallpaperId(String wallpaperId) async {
    final results = await _database.laconic
        .table('favorites')
        .where('wallpaper_id', wallpaperId)
        .get();

    if (results.isEmpty) return null;
    return FavoriteEntity.fromJson(results.first.toMap());
  }

  Future<void> insert(FavoriteEntity entity) async {
    await _database.laconic.table('favorites').insert([entity.toJson()]);
  }

  Future<void> delete(String id) async {
    await _database.laconic.table('favorites').where('id', id).delete();
  }

  Future<void> deleteByWallpaperId(String wallpaperId) async {
    await _database.laconic
        .table('favorites')
        .where('wallpaper_id', wallpaperId)
        .delete();
  }

  Future<bool> isFavorite(String wallpaperId) async {
    final count = await _database.laconic
        .table('favorites')
        .where('wallpaper_id', wallpaperId)
        .count();
    return count > 0;
  }

  Future<int> count() async {
    return await _database.laconic.table('favorites').count();
  }
}
