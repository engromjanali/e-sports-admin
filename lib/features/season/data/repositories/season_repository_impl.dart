import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/network/supabase_guard.dart';
import '../../domain/entities/season_entity.dart';
import '../../domain/repositories/season_repository.dart';
import '../datasources/season_data_source.dart';
import '../models/season_model.dart';

@LazySingleton(as: SeasonRepository)
class SeasonRepositoryImpl implements SeasonRepository {
  final SeasonDataSource _dataSource;

  SeasonRepositoryImpl(this._dataSource);

  SeasonModel _toModel(SeasonEntity e) => SeasonModel(
        id: e.id,
        name: e.name,
        startDate: e.startDate,
        endDate: e.endDate,
        isCurrent: e.isCurrent,
      );

  @override
  ResultFuture<List<SeasonEntity>> getSeasons() =>
      guardSupabase(() => _dataSource.getSeasons());

  @override
  ResultFuture<SeasonEntity> createSeason(SeasonEntity season) =>
      guardSupabase(() => _dataSource.createSeason(_toModel(season)));

  @override
  ResultFuture<SeasonEntity> updateSeason(SeasonEntity season) =>
      guardSupabase(
        () => _dataSource.updateSeason(season.id, _toModel(season)),
      );

  @override
  ResultVoid deleteSeason(int id) =>
      guardSupabaseVoid(() => _dataSource.deleteSeason(id));

  @override
  ResultVoid setCurrent(int id) =>
      guardSupabaseVoid(() => _dataSource.setCurrent(id));
}
