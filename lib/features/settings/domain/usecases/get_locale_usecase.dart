import 'package:injectable/injectable.dart';
import '../../../../config/util/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/settings_repository.dart';

/// UseCase to get the current locale code
@lazySingleton
class GetLocaleUseCase implements UseCase<String, NoParams> {
  final SettingsRepository _repository;

  GetLocaleUseCase(this._repository);

  @override
  ResultFuture<String> call(NoParams params) {
    return _repository.getLocale();
  }
}
