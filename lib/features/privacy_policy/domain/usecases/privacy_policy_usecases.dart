import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/privacy_policy_entity.dart';
import '../repositories/privacy_policy_repository.dart';

@lazySingleton
class GetPrivacyPolicyUseCase
    implements UseCase<PrivacyPolicyEntity?, NoParams> {
  final PrivacyPolicyRepository _repository;
  GetPrivacyPolicyUseCase(this._repository);

  @override
  ResultFuture<PrivacyPolicyEntity?> call(NoParams params) =>
      _repository.getPrivacyPolicy();
}

@lazySingleton
class SavePrivacyPolicyUseCase
    implements UseCase<PrivacyPolicyEntity, PrivacyPolicyEntity> {
  final PrivacyPolicyRepository _repository;
  SavePrivacyPolicyUseCase(this._repository);

  @override
  ResultFuture<PrivacyPolicyEntity> call(PrivacyPolicyEntity params) =>
      _repository.savePrivacyPolicy(params);
}
