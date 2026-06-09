import '../../domain/entities/player_entity.dart';

class PlayerModel extends PlayerEntity {
  const PlayerModel({
    required super.id,
    required super.name,
    super.sortName,
    super.profileImageUrl,
    super.jerseyNumber,
    super.playerRoles,
    super.customTags,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sortName: json['sort_name'] as String?,
      profileImageUrl: json['profileimageurl'] as String?,
      jerseyNumber: (json['jerseynumber'] as num?)?.toInt(),
      playerRoles: (json['playerroles'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      customTags: (json['customtags'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  /// Map used for inserts/updates (`id`/`createdat` are DB-managed).
  Map<String, dynamic> toWriteMap() {
    return {
      'name': name,
      'sort_name': sortName,
      'profileimageurl': profileImageUrl,
      'jerseynumber': jerseyNumber,
      'playerroles': playerRoles,
      'customtags': customTags,
    };
  }
}
