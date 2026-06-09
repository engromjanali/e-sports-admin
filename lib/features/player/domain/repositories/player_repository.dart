import '../../../../config/util/result.dart';
import '../entities/player_entity.dart';

abstract class PlayerRepository {
  ResultFuture<List<PlayerEntity>> getPlayers();
  ResultFuture<PlayerEntity> createPlayer(PlayerEntity player);
  ResultFuture<PlayerEntity> updatePlayer(PlayerEntity player);
  ResultVoid deletePlayer(String id);
}
