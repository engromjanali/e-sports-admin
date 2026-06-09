import 'package:equatable/equatable.dart';

/// Allowed match statuses (matches the `matches.status` CHECK constraint).
const List<String> kMatchStatuses = [
  'upcoming',
  'live',
  'completed',
  'cancelled',
];

/// A fixture/match. Maps to the `matches` table.
class MatchEntity extends Equatable {
  final String id;
  final int seasonId;
  final String homeTeam;
  final String awayTeam;
  final int? homeScore;
  final int? awayScore;
  final String date;
  final String competition;
  final String status;

  const MatchEntity({
    required this.id,
    required this.seasonId,
    required this.homeTeam,
    required this.awayTeam,
    required this.date,
    required this.competition,
    required this.status,
    this.homeScore,
    this.awayScore,
  });

  String get title => '$homeTeam vs $awayTeam';

  String get scoreLine =>
      (homeScore == null || awayScore == null) ? '—' : '$homeScore : $awayScore';

  @override
  List<Object?> get props => [
        id,
        seasonId,
        homeTeam,
        awayTeam,
        homeScore,
        awayScore,
        date,
        competition,
        status,
      ];
}
