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

  const PlayerEntity({
    required this.id,
    required this.name,
    this.sortName,
    this.profileImageUrl,
    this.jerseyNumber,
    this.playerRoles = const [],
    this.customTags = const [],
  });

  @override
  List<Object?> get props =>
      [id, name, sortName, profileImageUrl, jerseyNumber, playerRoles, customTags];
}
