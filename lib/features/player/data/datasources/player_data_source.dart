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

  static const String _selectWithRelations =
      '*, player_player_roles(role_id, player_role(id, name)), player_custom_tags(tag_id, custom_tags(id, name))';

  @override
  Future<List<PlayerModel>> getPlayers() async {
    final data = await _table.select(_selectWithRelations).order('name');
    return (data as List)
        .map((e) => PlayerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PlayerModel> createPlayer(PlayerModel player) async {
    final data = await _table
        .insert(player.toWriteMap())
        .select()
        .single();
    final created = PlayerModel.fromJson(data);
    await _syncJunctions(created.id, player.playerRoles, player.customTags);
    return _fetchOne(created.id);
  }

  @override
  Future<PlayerModel> updatePlayer(String id, PlayerModel player) async {
    await _table.update(player.toWriteMap()).eq('id', id);
    await _syncJunctions(id, player.playerRoles, player.customTags);
    return _fetchOne(id);
  }

  @override
  Future<void> deletePlayer(String id) async {
    await _table.delete().eq('id', id);
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  Future<PlayerModel> _fetchOne(String id) async {
    final data = await _table
        .select(_selectWithRelations)
        .eq('id', id)
        .single();
    return PlayerModel.fromJson(data);
  }

  /// Replace all junction entries for [playerId] with the supplied names.
  Future<void> _syncJunctions(
    String playerId,
    List<String> roleNames,
    List<String> tagNames,
  ) async {
    await _client.from('player_player_roles').delete().eq('player_id', playerId);
    await _client.from('player_custom_tags').delete().eq('player_id', playerId);

    if (roleNames.isNotEmpty) {
      final roles = await _client
          .from('player_role')
          .select('id, name')
          .inFilter('name', roleNames);
      if ((roles as List).isNotEmpty) {
        await _client.from('player_player_roles').insert(
          roles
              .map((r) => {'player_id': playerId, 'role_id': r['id']})
              .toList(),
        );
      }
    }

    if (tagNames.isNotEmpty) {
      final tags = await _client
          .from('custom_tags')
          .select('id, name')
          .inFilter('name', tagNames);
      if ((tags as List).isNotEmpty) {
        await _client.from('player_custom_tags').insert(
          tags
              .map((t) => {'player_id': playerId, 'tag_id': t['id']})
              .toList(),
        );
      }
    }
  }
}
