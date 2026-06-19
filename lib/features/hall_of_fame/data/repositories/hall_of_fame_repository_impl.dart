import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/network/supabase_guard.dart';
import '../../domain/entities/hall_of_fame_entity.dart';
import '../../domain/repositories/hall_of_fame_repository.dart';
import '../datasources/hall_of_fame_data_source.dart';
import '../models/hall_of_fame_model.dart';

@LazySingleton(as: HallOfFameRepository)
class HallOfFameRepositoryImpl implements HallOfFameRepository {
  final HallOfFameDataSource _dataSource;

  HallOfFameRepositoryImpl(this._dataSource);

  HallOfFameModel _toModel(HallOfFameEntity e) => HallOfFameModel(
        id: e.id,
        category: e.category,
        season: e.season,
        playerId: e.playerId,
        playerName: e.playerName,
        team: e.team,
        detail: e.detail,
        sortOrder: e.sortOrder,
      );

  @override
  ResultFuture<List<HallOfFameEntity>> getEntries() =>
      guardSupabase(() => _dataSource.getEntries());

  @override
  ResultFuture<HallOfFameEntity> createEntry(HallOfFameEntity entry) =>
      guardSupabase(() => _dataSource.createEntry(_toModel(entry)));

  @override
  ResultFuture<HallOfFameEntity> updateEntry(HallOfFameEntity entry) =>
      guardSupabase(() => _dataSource.updateEntry(entry.id, _toModel(entry)));

  @override
  ResultVoid deleteEntry(String id) =>
      guardSupabaseVoid(() => _dataSource.deleteEntry(id));
}
