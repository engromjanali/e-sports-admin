import 'package:injectable/injectable.dart';
import 'package:supabase/supabase.dart';

import '../../../../config/util/app_constants.dart';
import '../models/privacy_policy_model.dart';

abstract class PrivacyPolicyDataSource {
  Future<PrivacyPolicyModel?> getPrivacyPolicy();
  Future<PrivacyPolicyModel> savePrivacyPolicy(PrivacyPolicyModel policy);
}

@LazySingleton(as: PrivacyPolicyDataSource)
class PrivacyPolicyRemoteDataSource implements PrivacyPolicyDataSource {
  final SupabaseClient _client;

  PrivacyPolicyRemoteDataSource(this._client);

  SupabaseQueryBuilder get _table =>
      _client.from(AppConstants.tablePrivacyPolicy);

  @override
  Future<PrivacyPolicyModel?> getPrivacyPolicy() async {
    final data = await _table
        .select()
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return PrivacyPolicyModel.fromJson(data);
  }

  @override
  Future<PrivacyPolicyModel> savePrivacyPolicy(PrivacyPolicyModel policy) async {
    // Privacy policy is a single record: update the existing row when present,
    // otherwise insert the first one.
    if (policy.id != 0) {
      final data = await _table
          .update(policy.toWriteMap())
          .eq('id', policy.id)
          .select()
          .single();
      return PrivacyPolicyModel.fromJson(data);
    }
    final data = await _table.insert(policy.toWriteMap()).select().single();
    return PrivacyPolicyModel.fromJson(data);
  }
}
