import 'package:equatable/equatable.dart';

/// App-wide settings. Maps to the single `app_settings` row.
class AppSettingsEntity extends Equatable {
  final int id;
  final int? currentSeasonId;
  final String? version;
  final bool verifyEmail;
  final bool maintenanceMode;
  final bool userSelfRegistration;

  const AppSettingsEntity({
    required this.id,
    this.currentSeasonId,
    this.version,
    this.verifyEmail = false,
    this.maintenanceMode = false,
    this.userSelfRegistration = true,
  });

  AppSettingsEntity copyWith({
    int? currentSeasonId,
    String? version,
    bool? verifyEmail,
    bool? maintenanceMode,
    bool? userSelfRegistration,
    bool clearCurrentSeason = false,
  }) {
    return AppSettingsEntity(
      id: id,
      currentSeasonId:
          clearCurrentSeason ? null : (currentSeasonId ?? this.currentSeasonId),
      version: version ?? this.version,
      verifyEmail: verifyEmail ?? this.verifyEmail,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      userSelfRegistration: userSelfRegistration ?? this.userSelfRegistration,
    );
  }

  @override
  List<Object?> get props => [
        id,
        currentSeasonId,
        version,
        verifyEmail,
        maintenanceMode,
        userSelfRegistration,
      ];
}
