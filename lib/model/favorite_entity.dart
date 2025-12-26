/// Favorite Entity (local storage)
class FavoriteEntity {
  final String id;
  final String wallpaperId;
  final String thumbnailUrl;
  final String originalUrl;
  final String resolution;
  final String? category;
  final String? purity;
  final int createdAt;

  FavoriteEntity({
    required this.id,
    required this.wallpaperId,
    required this.thumbnailUrl,
    required this.originalUrl,
    required this.resolution,
    this.category,
    this.purity,
    required this.createdAt,
  });

  factory FavoriteEntity.fromJson(Map<String, dynamic> json) {
    return FavoriteEntity(
      id: json['id'] as String,
      wallpaperId: json['wallpaper_id'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      originalUrl: json['original_url'] as String,
      resolution: json['resolution'] as String,
      category: json['category'] as String?,
      purity: json['purity'] as String?,
      createdAt: json['created_at'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallpaper_id': wallpaperId,
      'thumbnail_url': thumbnailUrl,
      'original_url': originalUrl,
      'resolution': resolution,
      'category': category,
      'purity': purity,
      'created_at': createdAt,
    };
  }
}
