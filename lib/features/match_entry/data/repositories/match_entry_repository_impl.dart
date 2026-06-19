import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/network/supabase_guard.dart';
import '../../domain/entities/match_entry_entity.dart';
import '../../domain/repositories/match_entry_repository.dart';
import '../datasources/match_entry_data_source.dart';
import '../models/match_entry_model.dart';

@LazySingleton(as: MatchEntryRepository)
class MatchEntryRepositoryImpl implements MatchEntryRepository {
  final MatchEntryDataSource _dataSource;

  MatchEntryRepositoryImpl(this._dataSource);

  MatchEntryModel _toModel(MatchEntryEntity e) => MatchEntryModel(
        id: e.id,
        playerId: e.playerId,
        matchId: e.matchId,
        goals: e.goals,
        goalsConceded: e.goalsConceded,
        hattricks: e.hattricks,
        cleanSheet: e.cleanSheet,
        motm: e.motm,
        result: e.result,
        notes: e.notes,
        seasonId: e.seasonId,
      );

  @override
  ResultFuture<List<MatchEntryEntity>> getEntries(int seasonId) =>
      guardSupabase(() => _dataSource.getEntries(seasonId));

  @override
  ResultFuture<MatchEntryEntity> upsertEntry(MatchEntryEntity entry) =>
      guardSupabase(() => _dataSource.upsertEntry(_toModel(entry)));

  @override
  ResultVoid deleteEntry(String id) =>
      guardSupabaseVoid(() => _dataSource.deleteEntry(id));
}
