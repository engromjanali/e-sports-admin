import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/network/supabase_guard.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/match_repository.dart';
import '../datasources/match_data_source.dart';
import '../models/match_model.dart';

@LazySingleton(as: MatchRepository)
class MatchRepositoryImpl implements MatchRepository {
  final MatchDataSource _dataSource;

  MatchRepositoryImpl(this._dataSource);

  MatchModel _toModel(MatchEntity e) => MatchModel(
        id: e.id,
        seasonId: e.seasonId,
        homeTeam: e.homeTeam,
        awayTeam: e.awayTeam,
        homeScore: e.homeScore,
        awayScore: e.awayScore,
        date: e.date,
        competitionId: e.competitionId,
        status: e.status,
      );

  @override
  ResultFuture<List<MatchEntity>> getMatches({int? seasonId}) =>
      guardSupabase(() => _dataSource.getMatches(seasonId: seasonId));

  @override
  ResultFuture<MatchEntity> createMatch(MatchEntity match) =>
      guardSupabase(() => _dataSource.createMatch(_toModel(match)));

  @override
  ResultFuture<MatchEntity> updateMatch(MatchEntity match) =>
      guardSupabase(() => _dataSource.updateMatch(match.id, _toModel(match)));

  @override
  ResultVoid deleteMatch(String id) =>
      guardSupabaseVoid(() => _dataSource.deleteMatch(id));
}
