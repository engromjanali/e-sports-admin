import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/network/supabase_guard.dart';
import '../../domain/entities/privacy_policy_entity.dart';
import '../../domain/repositories/privacy_policy_repository.dart';
import '../datasources/privacy_policy_data_source.dart';
import '../models/privacy_policy_model.dart';

@LazySingleton(as: PrivacyPolicyRepository)
class PrivacyPolicyRepositoryImpl implements PrivacyPolicyRepository {
  final PrivacyPolicyDataSource _dataSource;

  PrivacyPolicyRepositoryImpl(this._dataSource);

  PrivacyPolicyModel _toModel(PrivacyPolicyEntity e) => PrivacyPolicyModel(
        id: e.id,
        content: e.content,
        updatedAt: e.updatedAt,
      );

  @override
  ResultFuture<PrivacyPolicyEntity?> getPrivacyPolicy() =>
      guardSupabase(() => _dataSource.getPrivacyPolicy());

  @override
  ResultFuture<PrivacyPolicyEntity> savePrivacyPolicy(
          PrivacyPolicyEntity policy) =>
      guardSupabase(() => _dataSource.savePrivacyPolicy(_toModel(policy)));
}
