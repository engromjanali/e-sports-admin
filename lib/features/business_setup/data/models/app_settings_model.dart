import '../../domain/entities/app_settings_entity.dart';

class AppSettingsModel extends AppSettingsEntity {
  const AppSettingsModel({
    required super.id,
    super.currentSeasonId,
    super.version,
    super.verifyEmail,
    super.maintenanceMode,
    super.userSelfRegistration,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      id: (json['id'] as num).toInt(),
      currentSeasonId: (json['current_season_id'] as num?)?.toInt(),
      version: json['version'] as String?,
      verifyEmail: json['verify_email'] as bool? ?? false,
      maintenanceMode: json['maintenance_mode'] as bool? ?? false,
      userSelfRegistration: json['user_self_registration'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'current_season_id': currentSeasonId,
      'version': version,
      'verify_email': verifyEmail,
      'maintenance_mode': maintenanceMode,
      'user_self_registration': userSelfRegistration,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
