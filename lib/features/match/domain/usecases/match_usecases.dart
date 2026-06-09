import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

class GetMatchesParams {
  final int? seasonId;
  const GetMatchesParams({this.seasonId});
}

@lazySingleton
class GetMatchesUseCase implements UseCase<List<MatchEntity>, GetMatchesParams> {
  final MatchRepository _repository;
  GetMatchesUseCase(this._repository);

  @override
  ResultFuture<List<MatchEntity>> call(GetMatchesParams params) =>
      _repository.getMatches(seasonId: params.seasonId);
}

@lazySingleton
class CreateMatchUseCase implements UseCase<MatchEntity, MatchEntity> {
  final MatchRepository _repository;
  CreateMatchUseCase(this._repository);

  @override
  ResultFuture<MatchEntity> call(MatchEntity params) =>
      _repository.createMatch(params);
}

@lazySingleton
class UpdateMatchUseCase implements UseCase<MatchEntity, MatchEntity> {
  final MatchRepository _repository;
  UpdateMatchUseCase(this._repository);

  @override
  ResultFuture<MatchEntity> call(MatchEntity params) =>
      _repository.updateMatch(params);
}

@lazySingleton
class DeleteMatchUseCase implements UseCase<void, String> {
  final MatchRepository _repository;
  DeleteMatchUseCase(this._repository);

  @override
  ResultVoid call(String params) => _repository.deleteMatch(params);
}
