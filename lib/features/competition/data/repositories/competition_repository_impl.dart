import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/network/supabase_guard.dart';
import '../../domain/entities/competition_entity.dart';
import '../../domain/repositories/competition_repository.dart';
import '../datasources/competition_data_source.dart';
import '../models/competition_model.dart';

@LazySingleton(as: CompetitionRepository)
class CompetitionRepositoryImpl implements CompetitionRepository {
  final CompetitionDataSource _dataSource;

  CompetitionRepositoryImpl(this._dataSource);

  CompetitionModel _toModel(CompetitionEntity e) => CompetitionModel(
        id: e.id,
        name: e.name,
        isActive: e.isActive,
      );

  @override
  ResultFuture<List<CompetitionEntity>> getCompetitions() =>
      guardSupabase(() => _dataSource.getCompetitions());

  @override
  ResultFuture<CompetitionEntity> createCompetition(CompetitionEntity competition) =>
      guardSupabase(() => _dataSource.createCompetition(_toModel(competition)));

  @override
  ResultFuture<CompetitionEntity> updateCompetition(CompetitionEntity competition) =>
      guardSupabase(
          () => _dataSource.updateCompetition(competition.id, _toModel(competition)));

  @override
  ResultVoid deleteCompetition(int id) =>
      guardSupabaseVoid(() => _dataSource.deleteCompetition(id));
}
