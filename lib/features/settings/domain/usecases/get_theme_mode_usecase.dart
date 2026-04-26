import 'package:injectable/injectable.dart';
import '../../../../config/util/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/theme_mode.dart';
import '../repositories/settings_repository.dart';

/// UseCase to get the current theme mode
@lazySingleton
class GetThemeModeUseCase implements UseCase<AppThemeMode, NoParams> {
  final SettingsRepository _repository;

  GetThemeModeUseCase(this._repository);

  @override
  ResultFuture<AppThemeMode> call(NoParams params) {
    return _repository.getThemeMode();
  }
}
