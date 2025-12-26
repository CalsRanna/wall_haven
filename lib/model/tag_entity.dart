/// Tag Entity
class TagEntity {
  final int id;
  final String name;
  final String alias;
  final int categoryId;
  final String category;
  final String purity;
  final DateTime createdAt;

  TagEntity({
    required this.id,
    required this.name,
    required this.alias,
    required this.categoryId,
    required this.category,
    required this.purity,
    required this.createdAt,
  });

  factory TagEntity.fromJson(Map<String, dynamic> json) {
    return TagEntity(
      id: _parseInt(json['id']),
      name: json['name'] as String,
      alias: json['alias'] as String? ?? '',
      categoryId: _parseInt(json['category_id']),
      category: json['category'] as String,
      purity: json['purity'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
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
      'name': name,
      'alias': alias,
      'category_id': categoryId,
      'category': category,
      'purity': purity,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
