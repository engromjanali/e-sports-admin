import '../../../../config/util/result.dart';
import '../entities/match_entity.dart';

abstract class MatchRepository {
  ResultFuture<List<MatchEntity>> getMatches({int? seasonId});
  ResultFuture<MatchEntity> createMatch(MatchEntity match);
  ResultFuture<MatchEntity> updateMatch(MatchEntity match);
  ResultVoid deleteMatch(String id);
}
