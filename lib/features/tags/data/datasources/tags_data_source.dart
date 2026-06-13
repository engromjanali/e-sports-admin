import 'package:supabase/supabase.dart';
import '../../domain/entities/tag_entity.dart';

class TagsDataSource {
  final SupabaseClient _client;

  TagsDataSource(this._client);

  // ── player_role ───────────────────────────────────────────────────────────

  Future<List<TagEntity>> getRoles() async {
    final data = await _client
        .from('player_role')
        .select('id, name')
        .order('name');
    return (data as List)
        .map((e) => TagEntity(id: (e['id'] as num).toInt(), name: e['name'] as String))
        .toList();
  }

  Future<TagEntity> createRole(String name) async {
    final data = await _client
        .from('player_role')
        .insert({'name': name})
        .select()
        .single();
    return TagEntity(id: (data['id'] as num).toInt(), name: data['name'] as String);
  }

  Future<void> deleteRole(int id) async {
    await _client.from('player_role').delete().eq('id', id);
  }

  // ── custom_tags ───────────────────────────────────────────────────────────

  Future<List<TagEntity>> getCustomTags() async {
    final data = await _client
        .from('custom_tags')
        .select('id, name')
        .order('name');
    return (data as List)
        .map((e) => TagEntity(id: (e['id'] as num).toInt(), name: e['name'] as String))
        .toList();
  }

  Future<TagEntity> createCustomTag(String name) async {
    final data = await _client
        .from('custom_tags')
        .insert({'name': name})
        .select()
        .single();
    return TagEntity(id: (data['id'] as num).toInt(), name: data['name'] as String);
  }

  Future<void> deleteCustomTag(int id) async {
    await _client.from('custom_tags').delete().eq('id', id);
  }
}
