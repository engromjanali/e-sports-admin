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
      playerRoles: _extractNames(json['player_player_roles'], 'player_role'),
      customTags: _extractNames(json['player_custom_tags'], 'custom_tags'),
    );
  }

  static List<String> _extractNames(dynamic list, String key) {
    if (list is! List) return const [];
    return list
        .map((item) =>
            (item[key] as Map<String, dynamic>?)?['name']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
  }

  /// Map used for inserts/updates — roles/tags are managed via junction tables.
  Map<String, dynamic> toWriteMap() {
    return {
      'name': name,
      'sort_name': sortName,
      'profileimageurl': profileImageUrl,
      'jerseynumber': jerseyNumber,
    };
  }
}
