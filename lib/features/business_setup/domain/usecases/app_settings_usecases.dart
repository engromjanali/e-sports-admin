import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_settings_entity.dart';
import '../repositories/app_settings_repository.dart';

@lazySingleton
class GetAppSettingsUseCase implements UseCase<AppSettingsEntity, NoParams> {
  final AppSettingsRepository _repository;
  GetAppSettingsUseCase(this._repository);

  @override
  ResultFuture<AppSettingsEntity> call(NoParams params) =>
      _repository.getSettings();
}

@lazySingleton
class UpdateAppSettingsUseCase
    implements UseCase<AppSettingsEntity, AppSettingsEntity> {
  final AppSettingsRepository _repository;
  UpdateAppSettingsUseCase(this._repository);

  @override
  ResultFuture<AppSettingsEntity> call(AppSettingsEntity params) =>
      _repository.updateSettings(params);
}
