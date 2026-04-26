import '../../../../config/util/result.dart';
import '../entities/user_entity.dart';

/// Auth repository interface (abstraction in domain layer)
abstract class AuthRepository {
  ResultFuture<UserEntity> login({
    required String email,
    required String password,
  });

  ResultFuture<void> logout();

  ResultFuture<UserEntity?> getCurrentUser();
}
