/// Collection entity representing a Wallhaven user collection
class CollectionEntity {
  final int id;
  final String label;
  final int views;
  final int wallpaperCount;
  final String purity;
  final bool public;
  final DateTime createdAt;

  CollectionEntity({
    required this.id,
    required this.label,
    required this.views,
    required this.wallpaperCount,
    required this.purity,
    required this.public,
    required this.createdAt,
  });

  factory CollectionEntity.fromJson(Map<String, dynamic> json) {
    return CollectionEntity(
      id: _parseInt(json['id']),
      label: json['label'] as String? ?? 'Untitled',
      views: _parseInt(json['views']),
      wallpaperCount: _parseInt(json['count']),
      purity: json['purity'] as String? ?? 'sfw',
      public: json['public'] == 1 || json['public'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
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
      'label': label,
      'views': views,
      'count': wallpaperCount,
      'purity': purity,
      'public': public ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
