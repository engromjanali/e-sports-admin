import 'package:injectable/injectable.dart';
import '../../../../config/util/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Logout use case
@lazySingleton
class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  @override
  ResultFuture<void> call(NoParams params) {
    return _repository.logout();
  }
}
