import 'package:equatable/equatable.dart';

/// Allowed per-player match results (matches the `match_entries.result` CHECK).
const List<String> kMatchResults = ['win', 'draw', 'loss'];

/// A single player's stat line for a match. Maps to `match_entries`.
///
/// [playerName], [playerImageUrl] and [jerseyNumber] are read-only display
/// fields populated from the joined `players` row.
class MatchEntryEntity extends Equatable {
  final String id;
  final String playerId;
  final String matchId;
  final int goals;
  final int goalsConceded;
  final int hattricks;
  final bool cleanSheet;
  final bool motm;
  final String result;
  final String notes;
  final String source;

  final int? seasonId;

  final String? playerName;
  final String? playerImageUrl;
  final int? jerseyNumber;

  const MatchEntryEntity({
    required this.id,
    required this.playerId,
    required this.matchId,
    this.goals = 0,
    this.goalsConceded = 0,
    this.hattricks = 0,
    this.cleanSheet = false,
    this.motm = false,
    this.result = 'draw',
    this.notes = '',
    this.source = 'manual',
    this.seasonId,
    this.playerName,
    this.playerImageUrl,
    this.jerseyNumber,
  });

  @override
  List<Object?> get props => [
        id,
        playerId,
        matchId,
        goals,
        goalsConceded,
        hattricks,
        cleanSheet,
        motm,
        result,
        notes,
        source,
        seasonId,
        playerName,
        playerImageUrl,
        jerseyNumber,
      ];
}
