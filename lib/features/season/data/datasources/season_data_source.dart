import 'package:injectable/injectable.dart';
import 'package:supabase/supabase.dart';

import '../../../../config/util/app_constants.dart';
import '../models/season_model.dart';

abstract class SeasonDataSource {
  Future<List<SeasonModel>> getSeasons();
  Future<SeasonModel> createSeason(SeasonModel season);
  Future<SeasonModel> updateSeason(int id, SeasonModel season);
  Future<void> deleteSeason(int id);
  Future<void> setCurrent(int id);
}

@LazySingleton(as: SeasonDataSource)
class SeasonRemoteDataSource implements SeasonDataSource {
  final SupabaseClient _client;

  SeasonRemoteDataSource(this._client);

  SupabaseQueryBuilder get _table =>
      _client.from(AppConstants.tableSeason);

  @override
  Future<List<SeasonModel>> getSeasons() async {
    final data = await _table.select().order('start_date', ascending: false);
    return (data as List)
        .map((e) => SeasonModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SeasonModel> createSeason(SeasonModel season) async {
    final data = await _table.insert(season.toWriteMap()).select().single();
    return SeasonModel.fromJson(data);
  }

  @override
  Future<SeasonModel> updateSeason(int id, SeasonModel season) async {
    final data = await _table
        .update(season.toWriteMap())
        .eq('id', id)
        .select()
        .single();
    return SeasonModel.fromJson(data);
  }

  @override
  Future<void> deleteSeason(int id) async {
    await _table.delete().eq('id', id);
  }

  @override
  Future<void> setCurrent(int id) async {
    // Only one season may be current (enforced by a partial unique index).
    // Clear the existing current season first, then promote the chosen one.
    await _table.update({'is_current': false}).eq('is_current', true);
    await _table.update({'is_current': true}).eq('id', id);
  }
}
