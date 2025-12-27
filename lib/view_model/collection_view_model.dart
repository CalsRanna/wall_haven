import 'package:get_it/get_it.dart';
import 'package:signals/signals.dart';
import '../model/collection_entity.dart';
import '../model/wallpaper_entity.dart';
import '../service/wall_haven_api_service.dart';
import '../util/logger_util.dart';

/// ViewModel for managing user collections
class CollectionViewModel {
  final _apiService = GetIt.instance.get<WallHavenApiService>();

  // Collections list state
  final collections = listSignal<CollectionEntity>([]);
  final isLoading = signal(false);
  final error = signal<String?>(null);
  final currentUsername = signal<String?>(null);

  // Collection wallpapers state
  final collectionWallpapers = listSignal<WallpaperEntity>([]);
  final isLoadingWallpapers = signal(false);
  final wallpapersError = signal<String?>(null);
  final currentCollectionPage = signal(1);
  final hasMoreWallpapers = signal(true);

  /// Load current user's collections (requires API key)
  Future<void> loadMyCollections() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = null;
    currentUsername.value = null;

    try {
      final result = await _apiService.getMyCollections();
      collections.value = result;
      LoggerUtil.instance.i('Loaded ${result.length} collections');
    } catch (e) {
      error.value = e.toString();
      LoggerUtil.instance.e('Failed to load collections', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Load a specific user's public collections
  Future<void> loadUserCollections(String username) async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = null;
    currentUsername.value = username;

    try {
      final result = await _apiService.getUserCollections(username);
      collections.value = result;
      LoggerUtil.instance.i('Loaded ${result.length} collections for $username');
    } catch (e) {
      error.value = e.toString();
      LoggerUtil.instance.e('Failed to load collections for $username', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Load wallpapers from a collection
  Future<void> loadCollectionWallpapers({
    required String username,
    required int collectionId,
    bool refresh = false,
  }) async {
    if (isLoadingWallpapers.value) return;

    if (refresh) {
      currentCollectionPage.value = 1;
      collectionWallpapers.value = [];
      hasMoreWallpapers.value = true;
    }

    isLoadingWallpapers.value = true;
    wallpapersError.value = null;

    try {
      final result = await _apiService.getCollectionWallpapers(
        username: username,
        collectionId: collectionId,
        page: currentCollectionPage.value,
      );

      if (currentCollectionPage.value == 1) {
        collectionWallpapers.value = result.data;
      } else {
        collectionWallpapers.value = [
          ...collectionWallpapers.value,
          ...result.data,
        ];
      }

      hasMoreWallpapers.value = result.meta.currentPage < result.meta.lastPage;
      LoggerUtil.instance.i(
        'Loaded collection wallpapers: page ${currentCollectionPage.value}, total ${result.meta.total}',
      );
    } catch (e) {
      wallpapersError.value = e.toString();
      LoggerUtil.instance.e('Failed to load collection wallpapers', e);
    } finally {
      isLoadingWallpapers.value = false;
    }
  }

  /// Load more wallpapers from the current collection
  Future<void> loadMoreWallpapers({
    required String username,
    required int collectionId,
  }) async {
    if (!hasMoreWallpapers.value || isLoadingWallpapers.value) return;
    currentCollectionPage.value++;
    await loadCollectionWallpapers(
      username: username,
      collectionId: collectionId,
    );
  }

  /// Clear collection wallpapers state
  void clearWallpapers() {
    collectionWallpapers.value = [];
    currentCollectionPage.value = 1;
    hasMoreWallpapers.value = true;
    wallpapersError.value = null;
  }

  /// Clear all state
  void clear() {
    collections.value = [];
    currentUsername.value = null;
    error.value = null;
    clearWallpapers();
  }
}
