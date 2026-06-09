import 'package:injectable/injectable.dart';
import 'package:supabase/supabase.dart';

import '../../../../config/util/app_constants.dart';
import '../models/player_model.dart';

abstract class PlayerDataSource {
  Future<List<PlayerModel>> getPlayers();
  Future<PlayerModel> createPlayer(PlayerModel player);
  Future<PlayerModel> updatePlayer(String id, PlayerModel player);
  Future<void> deletePlayer(String id);
}

@LazySingleton(as: PlayerDataSource)
class PlayerRemoteDataSource implements PlayerDataSource {
  final SupabaseClient _client;

  PlayerRemoteDataSource(this._client);

  SupabaseQueryBuilder get _table =>
      _client.from(AppConstants.tablePlayers);

  @override
  Future<List<PlayerModel>> getPlayers() async {
    final data = await _table.select().order('name');
    return (data as List)
        .map((e) => PlayerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PlayerModel> createPlayer(PlayerModel player) async {
    final data = await _table.insert(player.toWriteMap()).select().single();
    return PlayerModel.fromJson(data);
  }

  @override
  Future<PlayerModel> updatePlayer(String id, PlayerModel player) async {
    final data = await _table
        .update(player.toWriteMap())
        .eq('id', id)
        .select()
        .single();
    return PlayerModel.fromJson(data);
  }

  @override
  Future<void> deletePlayer(String id) async {
    await _table.delete().eq('id', id);
  }
}
