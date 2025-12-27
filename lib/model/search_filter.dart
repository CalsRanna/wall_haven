/// Category options for wallpaper search
enum WallpaperCategory {
  general('General', 0),
  anime('Anime', 1),
  people('People', 2);

  final String label;
  final int bitIndex;
  const WallpaperCategory(this.label, this.bitIndex);
}

/// Purity options for wallpaper search
enum WallpaperPurity {
  sfw('SFW', 0),
  sketchy('Sketchy', 1),
  nsfw('NSFW', 2);

  final String label;
  final int bitIndex;
  const WallpaperPurity(this.label, this.bitIndex);
}

/// Sorting options for search results
enum SortingOption {
  dateAdded('date_added', 'Date Added'),
  relevance('relevance', 'Relevance'),
  random('random', 'Random'),
  views('views', 'Views'),
  favorites('favorites', 'Favorites'),
  toplist('toplist', 'Top List');

  final String value;
  final String label;
  const SortingOption(this.value, this.label);
}

/// Sort order options
enum SortOrder {
  desc('desc', 'Descending'),
  asc('asc', 'Ascending');

  final String value;
  final String label;
  const SortOrder(this.value, this.label);
}

/// Preset resolutions for quick selection
class ResolutionPreset {
  static const Map<String, String> desktop = {
    '1920x1080': '1080p (FHD)',
    '2560x1440': '1440p (2K)',
    '3840x2160': '2160p (4K)',
    '2560x1080': 'Ultra Wide (21:9)',
    '3440x1440': 'Ultra Wide QHD',
  };

  static const Map<String, String> mobile = {
    '1080x1920': 'FHD Portrait',
    '1440x2560': 'QHD Portrait',
    '1080x2340': 'Modern Phone',
    '1080x2400': 'Tall Phone',
  };

  static Map<String, String> get all => {...desktop, ...mobile};
}

/// Preset aspect ratios for quick selection
class RatioPreset {
  static const Map<String, String> ratios = {
    '16x9': '16:9 (Widescreen)',
    '16x10': '16:10',
    '21x9': '21:9 (Ultra Wide)',
    '32x9': '32:9 (Super Wide)',
    '4x3': '4:3',
    '9x16': '9:16 (Portrait)',
    '10x16': '10:16 (Portrait)',
    '1x1': '1:1 (Square)',
  };
}

/// Search filter model containing all filter options
class SearchFilter {
  final Set<WallpaperCategory> categories;
  final Set<WallpaperPurity> purities;
  final SortingOption sorting;
  final SortOrder order;
  final String? atleast;
  final String? resolutions;
  final String? ratios;
  final String? colors;

  const SearchFilter({
    this.categories = const {
      WallpaperCategory.general,
      WallpaperCategory.anime,
      WallpaperCategory.people,
    },
    this.purities = const {WallpaperPurity.sfw},
    this.sorting = SortingOption.dateAdded,
    this.order = SortOrder.desc,
    this.atleast,
    this.resolutions,
    this.ratios,
    this.colors,
  });

  /// Convert categories to API format (e.g., '111' for all selected)
  String get categoriesParam {
    final bits = ['0', '0', '0'];
    for (final cat in categories) {
      bits[cat.bitIndex] = '1';
    }
    return bits.join();
  }

  /// Convert purities to API format (e.g., '100' for SFW only)
  String get puritiesParam {
    final bits = ['0', '0', '0'];
    for (final purity in purities) {
      bits[purity.bitIndex] = '1';
    }
    return bits.join();
  }

  /// Check if filter has any non-default values
  bool get hasActiveFilters {
    return categories.length != 3 ||
        purities.length != 1 ||
        !purities.contains(WallpaperPurity.sfw) ||
        sorting != SortingOption.dateAdded ||
        order != SortOrder.desc ||
        atleast != null ||
        resolutions != null ||
        ratios != null ||
        colors != null;
  }

  SearchFilter copyWith({
    Set<WallpaperCategory>? categories,
    Set<WallpaperPurity>? purities,
    SortingOption? sorting,
    SortOrder? order,
    String? atleast,
    String? resolutions,
    String? ratios,
    String? colors,
    bool clearAtleast = false,
    bool clearResolutions = false,
    bool clearRatios = false,
    bool clearColors = false,
  }) {
    return SearchFilter(
      categories: categories ?? this.categories,
      purities: purities ?? this.purities,
      sorting: sorting ?? this.sorting,
      order: order ?? this.order,
      atleast: clearAtleast ? null : (atleast ?? this.atleast),
      resolutions: clearResolutions ? null : (resolutions ?? this.resolutions),
      ratios: clearRatios ? null : (ratios ?? this.ratios),
      colors: clearColors ? null : (colors ?? this.colors),
    );
  }

  /// Create default filter
  static const defaultFilter = SearchFilter();
}
