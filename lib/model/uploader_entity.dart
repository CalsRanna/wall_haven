/// Uploader Entity
class UploaderEntity {
  final String username;
  final String group;
  final UploaderAvatar avatar;

  UploaderEntity({
    required this.username,
    required this.group,
    required this.avatar,
  });

  factory UploaderEntity.fromJson(Map<String, dynamic> json) {
    return UploaderEntity(
      username: json['username'] as String,
      group: json['group'] as String,
      avatar: UploaderAvatar.fromJson(json['avatar'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'group': group,
      'avatar': avatar.toJson(),
    };
  }
}

/// Uploader Avatar with multiple sizes
class UploaderAvatar {
  final String large;    // 200px
  final String medium;   // 128px
  final String small;    // 32px
  final String tiny;     // 20px

  UploaderAvatar({
    required this.large,
    required this.medium,
    required this.small,
    required this.tiny,
  });

  factory UploaderAvatar.fromJson(Map<String, dynamic> json) {
    return UploaderAvatar(
      large: json['200px'] as String,
      medium: json['128px'] as String,
      small: json['32px'] as String,
      tiny: json['20px'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '200px': large,
      '128px': medium,
      '32px': small,
      '20px': tiny,
    };
  }
}
