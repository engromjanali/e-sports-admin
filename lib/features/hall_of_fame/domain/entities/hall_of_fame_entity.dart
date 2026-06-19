import 'package:equatable/equatable.dart';

/// Award categories shown on the client's Hall of Fame screen.
enum HofCategory {
  ballonDor('ballon_dor', "Ballon d'Or"),
  goldenBoot('golden_boot', 'Golden Boot'),
  intraBid('intra_bid', 'Intra Bid Tournament');

  final String key;
  final String label;
  const HofCategory(this.key, this.label);

  static HofCategory fromKey(String key) =>
      HofCategory.values.firstWhere(
        (c) => c.key == key,
        orElse: () => HofCategory.ballonDor,
      );
}

/// A Hall of Fame inductee row. Every entry links to a player ([playerId]) —
/// the client shows that player's name and photo. [team] and [detail] are
/// free-text supporting lines.
class HallOfFameEntity extends Equatable {
  final String id;
  final HofCategory category;
  final String season;
  final String playerId;
  final String? playerName; // resolved from the players join (read-only)
  final String team;
  final String detail;
  final int sortOrder;

  const HallOfFameEntity({
    required this.id,
    required this.category,
    required this.season,
    required this.playerId,
    this.playerName,
    this.team = '',
    this.detail = '',
    this.sortOrder = 0,
  });

  /// The inductee name the client shows (the linked player's name).
  String get displayName => playerName ?? '';

  @override
  List<Object?> get props => [
        id,
        category,
        season,
        playerId,
        playerName,
        team,
        detail,
        sortOrder,
      ];
}
