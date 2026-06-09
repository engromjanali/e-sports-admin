import '../../../../config/util/result.dart';
import '../entities/app_settings_entity.dart';

abstract class AppSettingsRepository {
  ResultFuture<AppSettingsEntity> getSettings();
  ResultFuture<AppSettingsEntity> updateSettings(AppSettingsEntity settings);
}
