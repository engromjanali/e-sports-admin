import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/network/supabase_guard.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../datasources/app_settings_data_source.dart';
import '../models/app_settings_model.dart';

@LazySingleton(as: AppSettingsRepository)
class AppSettingsRepositoryImpl implements AppSettingsRepository {
  final AppSettingsDataSource _dataSource;

  AppSettingsRepositoryImpl(this._dataSource);

  AppSettingsModel _toModel(AppSettingsEntity e) => AppSettingsModel(
        id: e.id,
        currentSeasonId: e.currentSeasonId,
        version: e.version,
        verifyEmail: e.verifyEmail,
        maintenanceMode: e.maintenanceMode,
      );

  @override
  ResultFuture<AppSettingsEntity> getSettings() =>
      guardSupabase(() => _dataSource.getSettings());

  @override
  ResultFuture<AppSettingsEntity> updateSettings(AppSettingsEntity settings) =>
      guardSupabase(() => _dataSource.updateSettings(_toModel(settings)));
}
