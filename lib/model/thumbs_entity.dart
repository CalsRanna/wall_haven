/// Thumbnail Entity
class ThumbsEntity {
  final String large;
  final String original;
  final String small;

  ThumbsEntity({
    required this.large,
    required this.original,
    required this.small,
  });

  factory ThumbsEntity.fromJson(Map<String, dynamic> json) {
    return ThumbsEntity(
      large: json['large'] as String,
      original: json['original'] as String,
      small: json['small'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'large': large,
      'original': original,
      'small': small,
    };
  }
}
