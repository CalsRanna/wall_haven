import 'package:get_it/get_it.dart';
import 'package:signals/signals.dart';
import '../model/wallpaper_entity.dart';
import '../service/wall_haven_api_service.dart';
import '../util/logger_util.dart';

/// Time range options for Top List
enum TopRange {
  day('1d', '1 Day'),
  threeDays('3d', '3 Days'),
  week('1w', '1 Week'),
  month('1M', '1 Month'),
  threeMonths('3M', '3 Months'),
  sixMonths('6M', '6 Months'),
  year('1y', '1 Year');

  final String value;
  final String label;
  const TopRange(this.value, this.label);
}

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

/// ViewModel for Top List tab with time range selection
class TopListViewModel {
  final _apiService = GetIt.instance.get<WallHavenApiService>();

  // Reactive state
  final wallpapers = listSignal<WallpaperEntity>([]);
  final isLoading = signal(false);
  final error = signal<String?>(null);
  final currentPage = signal(1);
  final hasMore = signal(true);
  final categories = signal('111');
  final selectedRange = signal(TopRange.month);

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
        sorting: 'toplist',
        topRange: selectedRange.value.value,
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
        'Loaded top wallpapers [${selectedRange.value.value}]: page ${currentPage.value}, total ${result.meta.total}',
      );
    } catch (e) {
      error.value = e.toString();
      LoggerUtil.instance.e('Failed to load top wallpapers', e);
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

  Future<void> setTopRange(TopRange range) async {
    if (selectedRange.value == range) return;
    selectedRange.value = range;
    currentPage.value = 1;
    hasMore.value = true;
    wallpapers.value = [];
    await loadWallpapers();
  }
}

/// Main ViewModel managing all four tabs
class DiscoverViewModel {
  final latestViewModel = DiscoverTabViewModel(sorting: 'date_added');
  final popularViewModel = DiscoverTabViewModel(sorting: 'views');
  final randomViewModel = DiscoverTabViewModel(sorting: 'random');
  final topListViewModel = TopListViewModel();

  final currentIndex = signal(0);

  DiscoverTabViewModel? get currentTab {
    return switch (currentIndex.value) {
      0 => latestViewModel,
      1 => popularViewModel,
      2 => randomViewModel,
      _ => null, // Tab 3 uses TopListViewModel
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
      case 3:
        topListViewModel.ensureInitialized();
        break;
    }
  }
}
