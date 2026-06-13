import 'package:injectable/injectable.dart';
import 'package:supabase/supabase.dart';

import '../../../../config/util/app_constants.dart';
import '../models/match_model.dart';

abstract class MatchDataSource {
  Future<List<MatchModel>> getMatches({int? seasonId});
  Future<MatchModel> createMatch(MatchModel match);
  Future<MatchModel> updateMatch(String id, MatchModel match);
  Future<void> deleteMatch(String id);
}

@LazySingleton(as: MatchDataSource)
class MatchRemoteDataSource implements MatchDataSource {
  final SupabaseClient _client;

  MatchRemoteDataSource(this._client);

  SupabaseQueryBuilder get _table =>
      _client.from(AppConstants.tableMatches);

  @override
  Future<List<MatchModel>> getMatches({int? seasonId}) async {
    final filter = _table.select('*, competitions(name)');
    final query =
        seasonId != null ? filter.eq('season_id', seasonId) : filter;
    final data = await query.order('date', ascending: false);
    return (data as List)
        .map((e) => MatchModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MatchModel> createMatch(MatchModel match) async {
    final data = await _table.insert(match.toWriteMap()).select().single();
    return MatchModel.fromJson(data);
  }

  @override
  Future<MatchModel> updateMatch(String id, MatchModel match) async {
    final data =
        await _table.update(match.toWriteMap()).eq('id', id).select().single();
    return MatchModel.fromJson(data);
  }

  @override
  Future<void> deleteMatch(String id) async {
    await _table.delete().eq('id', id);
  }
}
