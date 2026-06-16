import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/season_entity.dart';
import '../repositories/season_repository.dart';

@lazySingleton
class GetSeasonsUseCase implements UseCase<List<SeasonEntity>, NoParams> {
  final SeasonRepository _repository;
  GetSeasonsUseCase(this._repository);

  @override
  ResultFuture<List<SeasonEntity>> call(NoParams params) =>
      _repository.getSeasons();
}

@lazySingleton
class CreateSeasonUseCase implements UseCase<SeasonEntity, SeasonEntity> {
  final SeasonRepository _repository;
  CreateSeasonUseCase(this._repository);

  @override
  ResultFuture<SeasonEntity> call(SeasonEntity params) =>
      _repository.createSeason(params);
}

@lazySingleton
class UpdateSeasonUseCase implements UseCase<SeasonEntity, SeasonEntity> {
  final SeasonRepository _repository;
  UpdateSeasonUseCase(this._repository);

  @override
  ResultFuture<SeasonEntity> call(SeasonEntity params) =>
      _repository.updateSeason(params);
}

@lazySingleton
class DeleteSeasonUseCase implements UseCase<void, int> {
  final SeasonRepository _repository;
  DeleteSeasonUseCase(this._repository);

  @override
  ResultVoid call(int params) => _repository.deleteSeason(params);
}
