import 'package:injectable/injectable.dart';
import 'package:supabase/supabase.dart';

import '../../../../config/util/app_constants.dart';
import '../models/match_entry_model.dart';

abstract class MatchEntryDataSource {
  Future<List<MatchEntryModel>> getEntries(String matchId);
  Future<MatchEntryModel> upsertEntry(MatchEntryModel entry);
  Future<void> deleteEntry(String id);
}

@LazySingleton(as: MatchEntryDataSource)
class MatchEntryRemoteDataSource implements MatchEntryDataSource {
  final SupabaseClient _client;

  MatchEntryRemoteDataSource(this._client);

  SupabaseQueryBuilder get _table =>
      _client.from(AppConstants.tableMatchEntries);

  // Includes the related player row for display (name, photo, jersey).
  static const String _selectWithPlayer =
      '*, players(name, profileimageurl, jerseynumber)';

  @override
  Future<List<MatchEntryModel>> getEntries(String matchId) async {
    final data =
        await _table.select(_selectWithPlayer).eq('matchid', matchId);
    return (data as List)
        .map((e) => MatchEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MatchEntryModel> upsertEntry(MatchEntryModel entry) async {
    // Unique(playerid, matchid): upsert so re-entering a player updates the row.
    final data = await _table
        .upsert(entry.toWriteMap(), onConflict: 'playerid,matchid')
        .select(_selectWithPlayer)
        .single();
    return MatchEntryModel.fromJson(data);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _table.delete().eq('id', id);
  }
}
