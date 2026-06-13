import '../../../../config/util/result.dart';
import '../entities/competition_entity.dart';

abstract class CompetitionRepository {
  ResultFuture<List<CompetitionEntity>> getCompetitions();
  ResultFuture<CompetitionEntity> createCompetition(CompetitionEntity competition);
  ResultFuture<CompetitionEntity> updateCompetition(CompetitionEntity competition);
  ResultVoid deleteCompetition(int id);
}
