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
    super.email,
    super.password,
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
      // Password is never read back into the form (left blank on edit).
      email: json['email'] as String?,
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
  ///
  /// `email`/`password` are only written when supplied: this keeps roster-only
  /// players (no account) intact and preserves the existing password on edit
  /// when the password field is left blank.
  Map<String, dynamic> toWriteMap() {
    final map = <String, dynamic>{
      'name': name,
      'sort_name': sortName,
      'profileimageurl': profileImageUrl,
      'jerseynumber': jerseyNumber,
    };
    if (email != null) map['email'] = email!.isEmpty ? null : email;
    if (password != null && password!.isNotEmpty) map['password'] = password;
    return map;
  }
}
