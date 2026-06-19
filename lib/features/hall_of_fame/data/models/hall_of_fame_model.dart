import '../../domain/entities/hall_of_fame_entity.dart';

class HallOfFameModel extends HallOfFameEntity {
  const HallOfFameModel({
    required super.id,
    required super.category,
    required super.season,
    required super.playerId,
    super.playerName,
    super.team,
    super.detail,
    super.sortOrder,
  });

  factory HallOfFameModel.fromJson(Map<String, dynamic> json) {
    final player = json['players'] as Map<String, dynamic>?;
    return HallOfFameModel(
      id: json['id']?.toString() ?? '',
      category: HofCategory.fromKey(json['category']?.toString() ?? ''),
      season: json['season']?.toString() ?? '',
      playerId: json['player_id']?.toString() ?? '',
      playerName: player?['name']?.toString(),
      team: json['team']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  /// Columns written on insert/update (excludes id and the read-only join).
  Map<String, dynamic> toWriteMap() {
    return {
      'category': category.key,
      'season': season,
      'player_id': playerId,
      'team': team,
      'detail': detail,
      'sort_order': sortOrder,
    };
  }
}
