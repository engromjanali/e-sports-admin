import '../../domain/entities/match_entity.dart';

class MatchModel extends MatchEntity {
  const MatchModel({
    required super.id,
    required super.seasonId,
    required super.homeTeam,
    required super.awayTeam,
    required super.date,
    required super.competition,
    required super.status,
    super.homeScore,
    super.awayScore,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id']?.toString() ?? '',
      seasonId: (json['season_id'] as num?)?.toInt() ?? 0,
      homeTeam: json['hometeam']?.toString() ?? '',
      awayTeam: json['awayteam']?.toString() ?? '',
      homeScore: (json['homescore'] as num?)?.toInt(),
      awayScore: (json['awayscore'] as num?)?.toInt(),
      date: json['date']?.toString() ?? '',
      competition: json['competition']?.toString() ?? '',
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
      'competition': competition,
      'status': status,
    };
  }
}
