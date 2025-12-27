import 'package:get_it/get_it.dart';
import 'package:signals/signals.dart';
import '../model/wallpaper_entity.dart';
import '../service/wall_haven_api_service.dart';
import '../util/logger_util.dart';

/// ViewModel for a single sorting tab (Latest/Popular/Random)
class DiscoverTabViewModel {
  final _apiService = GetIt.instance.get<WallHavenApiService>();
  final String sorting;

  DiscoverTabViewModel({required this.sorting});

  // Reactive state
  final wallpapers = listSignal<WallpaperEntity>([]);
  final isLoading = signal(false);
  final error = signal<String?>(null);
  final currentPage = signal(1);
  final hasMore = signal(true);
  final categories = signal('111');

  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    await loadWallpapers();
  }

  Future<void> loadWallpapers() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = null;

    try {
      final result = await _apiService.search(
        sorting: sorting,
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
        'Loaded wallpapers [$sorting]: page ${currentPage.value}, total ${result.meta.total}',
      );
    } catch (e) {
      error.value = e.toString();
      LoggerUtil.instance.e('Failed to load wallpapers [$sorting]', e);
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
}

/// Main ViewModel managing all three tabs
class DiscoverViewModel {
  final latestViewModel = DiscoverTabViewModel(sorting: 'date_added');
  final popularViewModel = DiscoverTabViewModel(sorting: 'views');
  final randomViewModel = DiscoverTabViewModel(sorting: 'random');

  final currentIndex = signal(0);

  DiscoverTabViewModel get currentTab {
    return switch (currentIndex.value) {
      0 => latestViewModel,
      1 => popularViewModel,
      2 => randomViewModel,
      _ => latestViewModel,
    };
  }

  Future<void> initSignals() async {
    // Only initialize the first tab on startup
    await latestViewModel.ensureInitialized();
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    // Initialize the tab when switched to
    switch (index) {
      case 0:
        latestViewModel.ensureInitialized();
        break;
      case 1:
        popularViewModel.ensureInitialized();
        break;
      case 2:
        randomViewModel.ensureInitialized();
        break;
    }
  }
}
