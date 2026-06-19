import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/hall_of_fame_entity.dart';
import '../repositories/hall_of_fame_repository.dart';

@lazySingleton
class GetHallOfFameUseCase implements UseCase<List<HallOfFameEntity>, NoParams> {
  final HallOfFameRepository _repository;
  GetHallOfFameUseCase(this._repository);

  @override
  ResultFuture<List<HallOfFameEntity>> call(NoParams params) =>
      _repository.getEntries();
}

@lazySingleton
class CreateHallOfFameUseCase
    implements UseCase<HallOfFameEntity, HallOfFameEntity> {
  final HallOfFameRepository _repository;
  CreateHallOfFameUseCase(this._repository);

  @override
  ResultFuture<HallOfFameEntity> call(HallOfFameEntity params) =>
      _repository.createEntry(params);
}

@lazySingleton
class UpdateHallOfFameUseCase
    implements UseCase<HallOfFameEntity, HallOfFameEntity> {
  final HallOfFameRepository _repository;
  UpdateHallOfFameUseCase(this._repository);

  @override
  ResultFuture<HallOfFameEntity> call(HallOfFameEntity params) =>
      _repository.updateEntry(params);
}

@lazySingleton
class DeleteHallOfFameUseCase implements UseCase<void, String> {
  final HallOfFameRepository _repository;
  DeleteHallOfFameUseCase(this._repository);

  @override
  ResultVoid call(String params) => _repository.deleteEntry(params);
}
