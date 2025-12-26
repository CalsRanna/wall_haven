import 'package:get_it/get_it.dart';
import 'package:signals/signals.dart';
import '../model/wallpaper_entity.dart';
import '../service/wall_haven_api_service.dart';
import '../util/logger_util.dart';

class DiscoverViewModel {
  final _apiService = GetIt.instance.get<WallHavenApiService>();

  // Reactive state
  final wallpapers = listSignal<WallpaperEntity>([]);
  final isLoading = signal(false);
  final error = signal<String?>(null);
  final currentPage = signal(1);
  final hasMore = signal(true);
  final sorting = signal('date_added');
  final categories = signal('111');

  // Computed property
  late final totalLoaded = computed(() => wallpapers.value.length);

  Future<void> initSignals() async {
    await loadWallpapers();
  }

  Future<void> loadWallpapers() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = null;

    try {
      final result = await _apiService.search(
        sorting: sorting.value,
        categories: categories.value,
        page: currentPage.value,
      );

      if (currentPage.value == 1) {
        wallpapers.value = result.data;
      } else {
        wallpapers.value = [...wallpapers.value, ...result.data];
      }

      hasMore.value = result.meta.currentPage < result.meta.lastPage;
      LoggerUtil.instance.i(
        'Loaded wallpapers: page ${currentPage.value}, total ${result.meta.total}',
      );
    } catch (e) {
      error.value = e.toString();
      LoggerUtil.instance.e('Failed to load wallpapers', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoading.value) return;
    currentPage.value++;
    await loadWallpapers();
  }

  Future<void> refresh() async {
    currentPage.value = 1;
    hasMore.value = true;
    await loadWallpapers();
  }

  void changeSorting(String newSorting) {
    if (sorting.value == newSorting) return;
    sorting.value = newSorting;
    currentPage.value = 1;
    loadWallpapers();
  }

  void changeCategories(String newCategories) {
    if (categories.value == newCategories) return;
    categories.value = newCategories;
    currentPage.value = 1;
    loadWallpapers();
  }
}
