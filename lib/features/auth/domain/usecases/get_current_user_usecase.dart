import 'package:injectable/injectable.dart';
import '../../../../config/util/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Get current user use case
@lazySingleton
class GetCurrentUserUseCase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  ResultFuture<UserEntity?> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}
