import 'wallpaper_entity.dart';

/// Search Result Metadata
class SearchMetaEntity {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? query;
  final String? seed;

  SearchMetaEntity({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.query,
    this.seed,
  });

  factory SearchMetaEntity.fromJson(Map<String, dynamic> json) {
    return SearchMetaEntity(
      currentPage: _parseInt(json['current_page']),
      lastPage: _parseInt(json['last_page']),
      perPage: _parseInt(json['per_page']),
      total: _parseInt(json['total']),
      query: json['query']?.toString(),
      seed: json['seed']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

/// Search Result
class SearchResultEntity {
  final List<WallpaperEntity> data;
  final SearchMetaEntity meta;

  SearchResultEntity({
    required this.data,
    required this.meta,
  });

  factory SearchResultEntity.fromJson(Map<String, dynamic> json) {
    return SearchResultEntity(
      data: (json['data'] as List<dynamic>)
          .map((e) => WallpaperEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: SearchMetaEntity.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}
