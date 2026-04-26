import 'package:injectable/injectable.dart';
import '../../../../config/util/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/settings_repository.dart';

/// Parameters for SetLocaleUseCase
class SetLocaleParams {
  final String localeCode;

  const SetLocaleParams({required this.localeCode});
}

/// UseCase to set a new locale
@lazySingleton
class SetLocaleUseCase implements UseCase<void, SetLocaleParams> {
  final SettingsRepository _repository;

  SetLocaleUseCase(this._repository);

  @override
  ResultVoid call(SetLocaleParams params) {
    return _repository.setLocale(params.localeCode);
  }
}
