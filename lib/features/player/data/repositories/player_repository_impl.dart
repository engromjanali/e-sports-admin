import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/network/supabase_guard.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/repositories/player_repository.dart';
import '../datasources/player_data_source.dart';
import '../models/player_model.dart';

@LazySingleton(as: PlayerRepository)
class PlayerRepositoryImpl implements PlayerRepository {
  final PlayerDataSource _dataSource;

  PlayerRepositoryImpl(this._dataSource);

  PlayerModel _toModel(PlayerEntity e) => PlayerModel(
        id: e.id,
        name: e.name,
        sortName: e.sortName,
        profileImageUrl: e.profileImageUrl,
        jerseyNumber: e.jerseyNumber,
        playerRoles: e.playerRoles,
        customTags: e.customTags,
      );

  @override
  ResultFuture<List<PlayerEntity>> getPlayers() =>
      guardSupabase(() => _dataSource.getPlayers());

  @override
  ResultFuture<PlayerEntity> createPlayer(PlayerEntity player) =>
      guardSupabase(() => _dataSource.createPlayer(_toModel(player)));

  @override
  ResultFuture<PlayerEntity> updatePlayer(PlayerEntity player) =>
      guardSupabase(() => _dataSource.updatePlayer(player.id, _toModel(player)));

  @override
  ResultVoid deletePlayer(String id) =>
      guardSupabaseVoid(() => _dataSource.deletePlayer(id));
}
