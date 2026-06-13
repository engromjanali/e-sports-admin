import '../../domain/entities/match_entity.dart';

class MatchModel extends MatchEntity {
  const MatchModel({
    required super.id,
    required super.seasonId,
    required super.homeTeam,
    required super.awayTeam,
    required super.date,
    required super.status,
    super.seasonName,
    super.competitionId,
    super.competitionName,
    super.homeScore,
    super.awayScore,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final comp = json['competitions'] as Map<String, dynamic>?;
    final season = json['season'] as Map<String, dynamic>?;
    return MatchModel(
      id: json['id']?.toString() ?? '',
      seasonId: (json['season_id'] as num?)?.toInt() ?? 0,
      seasonName: season?['name']?.toString(),
      homeTeam: json['hometeam']?.toString() ?? '',
      awayTeam: json['awayteam']?.toString() ?? '',
      homeScore: (json['homescore'] as num?)?.toInt(),
      awayScore: (json['awayscore'] as num?)?.toInt(),
      date: json['date']?.toString() ?? '',
      competitionId: (json['competition_id'] as num?)?.toInt(),
      competitionName: comp?['name']?.toString(),
      status: json['status']?.toString() ?? 'upcoming',
    );
  }

  /// Map used for inserts/updates (`id` is DB-managed).
  Map<String, dynamic> toWriteMap() {
    return {
      'season_id': seasonId,
      'hometeam': homeTeam,
      'awayteam': awayTeam,
      'homescore': homeScore,
      'awayscore': awayScore,
      'date': date,
      'competition_id': competitionId,
      'status': status,
    };
  }
}
