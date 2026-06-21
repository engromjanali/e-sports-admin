import 'package:equatable/equatable.dart';

/// A squad player. Maps to the `players` table.
class PlayerEntity extends Equatable {
  final String id;
  final String name;
  final String? sortName;
  final String? profileImageUrl;
  final int? jerseyNumber;
  final List<String> playerRoles;
  final List<String> customTags;

  /// Login email for the user app. Null for roster-only players without an account.
  final String? email;

  /// Plaintext login password (the user app authenticates on an exact match).
  /// Only set when creating an account or changing the password; null otherwise.
  final String? password;

  const PlayerEntity({
    required this.id,
    required this.name,
    this.sortName,
    this.profileImageUrl,
    this.jerseyNumber,
    this.playerRoles = const [],
    this.customTags = const [],
    this.email,
    this.password,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        sortName,
        profileImageUrl,
        jerseyNumber,
        playerRoles,
        customTags,
        email,
        password,
      ];
}
