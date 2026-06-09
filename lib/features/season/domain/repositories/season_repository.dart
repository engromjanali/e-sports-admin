import '../../../../config/util/result.dart';
import '../entities/season_entity.dart';

abstract class SeasonRepository {
  ResultFuture<List<SeasonEntity>> getSeasons();
  ResultFuture<SeasonEntity> createSeason(SeasonEntity season);
  ResultFuture<SeasonEntity> updateSeason(SeasonEntity season);
  ResultVoid deleteSeason(int id);
  ResultVoid setCurrent(int id);
}
