import 'package:injectable/injectable.dart';
import 'package:supabase/supabase.dart';

import '../../../../config/util/app_constants.dart';
import '../models/faq_model.dart';

abstract class FaqDataSource {
  Future<List<FaqModel>> getFaqs();
  Future<FaqModel> createFaq(FaqModel faq);
  Future<FaqModel> updateFaq(int id, FaqModel faq);
  Future<void> deleteFaq(int id);
}

@LazySingleton(as: FaqDataSource)
class FaqRemoteDataSource implements FaqDataSource {
  final SupabaseClient _client;

  FaqRemoteDataSource(this._client);

  SupabaseQueryBuilder get _table => _client.from(AppConstants.tableFaqs);

  @override
  Future<List<FaqModel>> getFaqs() async {
    final data = await _table
        .select()
        .order('display_order', ascending: true)
        .order('id', ascending: true);
    return (data as List)
        .map((e) => FaqModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FaqModel> createFaq(FaqModel faq) async {
    final data = await _table.insert(faq.toWriteMap()).select().single();
    return FaqModel.fromJson(data);
  }

  @override
  Future<FaqModel> updateFaq(int id, FaqModel faq) async {
    final data = await _table
        .update(faq.toWriteMap())
        .eq('id', id)
        .select()
        .single();
    return FaqModel.fromJson(data);
  }

  @override
  Future<void> deleteFaq(int id) async {
    await _table.delete().eq('id', id);
  }
}
