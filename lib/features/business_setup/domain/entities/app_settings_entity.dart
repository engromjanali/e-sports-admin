import 'package:equatable/equatable.dart';

/// App-wide settings. Maps to the single `app_settings` row.
class AppSettingsEntity extends Equatable {
  final int id;
  final int? currentSeasonId;
  final String? version;
  final bool verifyEmail;
  final bool maintenanceMode;

  const AppSettingsEntity({
    required this.id,
    this.currentSeasonId,
    this.version,
    this.verifyEmail = false,
    this.maintenanceMode = false,
  });

  AppSettingsEntity copyWith({
    int? currentSeasonId,
    String? version,
    bool? verifyEmail,
    bool? maintenanceMode,
    bool clearCurrentSeason = false,
  }) {
    return AppSettingsEntity(
      id: id,
      currentSeasonId:
          clearCurrentSeason ? null : (currentSeasonId ?? this.currentSeasonId),
      version: version ?? this.version,
      verifyEmail: verifyEmail ?? this.verifyEmail,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
    );
  }

  @override
  List<Object?> get props =>
      [id, currentSeasonId, version, verifyEmail, maintenanceMode];
}
