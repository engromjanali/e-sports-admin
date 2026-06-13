import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/competition_entity.dart';
import '../repositories/competition_repository.dart';

@lazySingleton
class GetCompetitionsUseCase implements UseCase<List<CompetitionEntity>, NoParams> {
  final CompetitionRepository _repository;
  GetCompetitionsUseCase(this._repository);

  @override
  ResultFuture<List<CompetitionEntity>> call(NoParams params) =>
      _repository.getCompetitions();
}

@lazySingleton
class CreateCompetitionUseCase implements UseCase<CompetitionEntity, CompetitionEntity> {
  final CompetitionRepository _repository;
  CreateCompetitionUseCase(this._repository);

  @override
  ResultFuture<CompetitionEntity> call(CompetitionEntity params) =>
      _repository.createCompetition(params);
}

@lazySingleton
class UpdateCompetitionUseCase implements UseCase<CompetitionEntity, CompetitionEntity> {
  final CompetitionRepository _repository;
  UpdateCompetitionUseCase(this._repository);

  @override
  ResultFuture<CompetitionEntity> call(CompetitionEntity params) =>
      _repository.updateCompetition(params);
}

@lazySingleton
class DeleteCompetitionUseCase implements UseCase<void, int> {
  final CompetitionRepository _repository;
  DeleteCompetitionUseCase(this._repository);

  @override
  ResultVoid call(int params) => _repository.deleteCompetition(params);
}
