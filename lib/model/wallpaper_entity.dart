import 'thumbs_entity.dart';
import 'tag_entity.dart';
import 'uploader_entity.dart';

/// Wallpaper Entity
class WallpaperEntity {
  final String id;
  final String url;
  final String shortUrl;
  final int views;
  final int favorites;
  final String source;
  final String purity;
  final String category;
  final int dimensionX;
  final int dimensionY;
  final String resolution;
  final String ratio;
  final int fileSize;
  final String fileType;
  final DateTime createdAt;
  final List<String> colors;
  final String path;
  final ThumbsEntity thumbs;
  final List<TagEntity>? tags;
  final UploaderEntity? uploader;

  WallpaperEntity({
    required this.id,
    required this.url,
    required this.shortUrl,
    required this.views,
    required this.favorites,
    required this.source,
    required this.purity,
    required this.category,
    required this.dimensionX,
    required this.dimensionY,
    required this.resolution,
    required this.ratio,
    required this.fileSize,
    required this.fileType,
    required this.createdAt,
    required this.colors,
    required this.path,
    required this.thumbs,
    this.tags,
    this.uploader,
  });

  factory WallpaperEntity.fromJson(Map<String, dynamic> json) {
    return WallpaperEntity(
      id: json['id'].toString(),
      url: json['url'] as String,
      shortUrl: json['short_url'] as String,
      views: _parseInt(json['views']),
      favorites: _parseInt(json['favorites']),
      source: json['source'] as String? ?? '',
      purity: json['purity'] as String,
      category: json['category'] as String,
      dimensionX: _parseInt(json['dimension_x']),
      dimensionY: _parseInt(json['dimension_y']),
      resolution: json['resolution'] as String,
      ratio: json['ratio'] as String,
      fileSize: _parseInt(json['file_size']),
      fileType: json['file_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      colors: (json['colors'] as List<dynamic>).cast<String>(),
      path: json['path'] as String,
      thumbs: ThumbsEntity.fromJson(json['thumbs'] as Map<String, dynamic>),
      tags: json['tags'] != null
          ? (json['tags'] as List<dynamic>)
              .map((e) => TagEntity.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      uploader: json['uploader'] != null
          ? UploaderEntity.fromJson(json['uploader'] as Map<String, dynamic>)
          : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'short_url': shortUrl,
      'views': views,
      'favorites': favorites,
      'source': source,
      'purity': purity,
      'category': category,
      'dimension_x': dimensionX,
      'dimension_y': dimensionY,
      'resolution': resolution,
      'ratio': ratio,
      'file_size': fileSize,
      'file_type': fileType,
      'created_at': createdAt.toIso8601String(),
      'colors': colors,
      'path': path,
      'thumbs': thumbs.toJson(),
      'tags': tags?.map((e) => e.toJson()).toList(),
      'uploader': uploader?.toJson(),
    };
  }

  /// Get readable file size format
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
