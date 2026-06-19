import '../../domain/entities/match_entry_entity.dart';

class MatchEntryModel extends MatchEntryEntity {
  const MatchEntryModel({
    required super.id,
    required super.playerId,
    super.matchId,
    super.goals,
    super.goalsConceded,
    super.hattricks,
    super.cleanSheet,
    super.motm,
    super.result,
    super.notes,
    super.seasonId,
    super.playerName,
    super.playerImageUrl,
    super.jerseyNumber,
  });

  factory MatchEntryModel.fromJson(Map<String, dynamic> json) {
    // Embedded player row from `select('*, players(...)')`.
    final player = json['players'] as Map<String, dynamic>?;
    return MatchEntryModel(
      id: json['id']?.toString() ?? '',
      playerId: json['playerid']?.toString() ?? '',
      matchId: json['matchid']?.toString() ?? '',
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      goalsConceded: (json['goalsconceded'] as num?)?.toInt() ?? 0,
      hattricks: (json['hattricks'] as num?)?.toInt() ?? 0,
      cleanSheet: json['cleansheet'] as bool? ?? false,
      motm: json['motm'] as bool? ?? false,
      result: json['result']?.toString() ?? 'draw',
      notes: json['notes']?.toString() ?? '',
      seasonId: (json['season_id'] as num?)?.toInt(),
      playerName: player?['name']?.toString(),
      playerImageUrl: player?['profileimageurl']?.toString(),
      jerseyNumber: (player?['jerseynumber'] as num?)?.toInt(),
    );
  }

  /// Columns written on insert/update. Display-only join fields and `matchid`
  /// (entries aren't tied to a match) are never written.
  Map<String, dynamic> toWriteMap() {
    return {
      'playerid': playerId,
      'goals': goals,
      'goalsconceded': goalsConceded,
      'hattricks': hattricks,
      'cleansheet': cleanSheet,
      'motm': motm,
      'result': result,
      'notes': notes,
      if (seasonId != null) 'season_id': seasonId,
    };
  }
}
