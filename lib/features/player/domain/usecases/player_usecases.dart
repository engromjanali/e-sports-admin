import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/player_entity.dart';
import '../repositories/player_repository.dart';

@lazySingleton
class GetPlayersUseCase implements UseCase<List<PlayerEntity>, NoParams> {
  final PlayerRepository _repository;
  GetPlayersUseCase(this._repository);

  @override
  ResultFuture<List<PlayerEntity>> call(NoParams params) =>
      _repository.getPlayers();
}

@lazySingleton
class CreatePlayerUseCase implements UseCase<PlayerEntity, PlayerEntity> {
  final PlayerRepository _repository;
  CreatePlayerUseCase(this._repository);

  @override
  ResultFuture<PlayerEntity> call(PlayerEntity params) =>
      _repository.createPlayer(params);
}

@lazySingleton
class UpdatePlayerUseCase implements UseCase<PlayerEntity, PlayerEntity> {
  final PlayerRepository _repository;
  UpdatePlayerUseCase(this._repository);

  @override
  ResultFuture<PlayerEntity> call(PlayerEntity params) =>
      _repository.updatePlayer(params);
}

@lazySingleton
class DeletePlayerUseCase implements UseCase<void, String> {
  final PlayerRepository _repository;
  DeletePlayerUseCase(this._repository);

  @override
  ResultVoid call(String params) => _repository.deletePlayer(params);
}
