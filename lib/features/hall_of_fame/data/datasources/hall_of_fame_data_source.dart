import 'package:injectable/injectable.dart';
import 'package:supabase/supabase.dart';

import '../../../../config/util/app_constants.dart';
import '../models/hall_of_fame_model.dart';

abstract class HallOfFameDataSource {
  Future<List<HallOfFameModel>> getEntries();
  Future<HallOfFameModel> createEntry(HallOfFameModel entry);
  Future<HallOfFameModel> updateEntry(String id, HallOfFameModel entry);
  Future<void> deleteEntry(String id);
}

@LazySingleton(as: HallOfFameDataSource)
class HallOfFameRemoteDataSource implements HallOfFameDataSource {
  final SupabaseClient _client;

  HallOfFameRemoteDataSource(this._client);

  SupabaseQueryBuilder get _table =>
      _client.from(AppConstants.tableHallOfFame);

  @override
  Future<List<HallOfFameModel>> getEntries() async {
    final data = await _table
        .select('*, players(name)')
        .order('category', ascending: true)
        .order('sort_order', ascending: true);
    return (data as List)
        .map((e) => HallOfFameModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<HallOfFameModel> createEntry(HallOfFameModel entry) async {
    final data =
        await _table.insert(entry.toWriteMap()).select('*, players(name)').single();
    return HallOfFameModel.fromJson(data);
  }

  @override
  Future<HallOfFameModel> updateEntry(String id, HallOfFameModel entry) async {
    final data = await _table
        .update(entry.toWriteMap())
        .eq('id', id)
        .select('*, players(name)')
        .single();
    return HallOfFameModel.fromJson(data);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _table.delete().eq('id', id);
  }
}
