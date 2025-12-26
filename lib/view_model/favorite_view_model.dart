import 'package:signals/signals.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../model/favorite_entity.dart';
import '../model/wallpaper_entity.dart';
import '../repository/favorite_repository.dart';
import '../util/logger_util.dart';

class FavoriteViewModel {
  late final FavoriteRepository _repository;
  final Uuid _uuid = const Uuid();

  final favorites = listSignal<FavoriteEntity>([]);
  final isLoading = signal(false);

  FavoriteViewModel() {
    _repository = FavoriteRepository(Database.instance);
  }

  Future<void> initSignals() async {
    await loadFavorites();
  }

  Future<void> loadFavorites() async {
    isLoading.value = true;
    try {
      final result = await _repository.getAll();
      favorites.value = result;
      LoggerUtil.instance.i('Loaded favorites: ${result.length}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(WallpaperEntity wallpaper) async {
    final isFav = await _repository.isFavorite(wallpaper.id);

    if (isFav) {
      await _repository.deleteByWallpaperId(wallpaper.id);
      LoggerUtil.instance.i('Removed from favorites: ${wallpaper.id}');
    } else {
      final entity = FavoriteEntity(
        id: _uuid.v4(),
        wallpaperId: wallpaper.id,
        thumbnailUrl: wallpaper.thumbs.large,
        originalUrl: wallpaper.path,
        resolution: wallpaper.resolution,
        category: wallpaper.category,
        purity: wallpaper.purity,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _repository.insert(entity);
      LoggerUtil.instance.i('Added to favorites: ${wallpaper.id}');
    }

    await loadFavorites();
  }

  Future<bool> isFavorite(String wallpaperId) async {
    return await _repository.isFavorite(wallpaperId);
  }
}
