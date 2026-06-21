import '../../../../config/util/result.dart';
import '../entities/privacy_policy_entity.dart';

abstract class PrivacyPolicyRepository {
  ResultFuture<PrivacyPolicyEntity?> getPrivacyPolicy();
  ResultFuture<PrivacyPolicyEntity> savePrivacyPolicy(PrivacyPolicyEntity policy);
}
