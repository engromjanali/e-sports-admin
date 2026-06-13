import 'package:clean_boilerplate/core/methods/printer.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase/supabase.dart';

import '../../../../config/util/app_constants.dart';
import '../models/competition_model.dart';

abstract class CompetitionDataSource {
  Future<List<CompetitionModel>> getCompetitions();
  Future<CompetitionModel> createCompetition(CompetitionModel competition);
  Future<CompetitionModel> updateCompetition(int id, CompetitionModel competition);
  Future<void> deleteCompetition(int id);
}

@LazySingleton(as: CompetitionDataSource)
class CompetitionRemoteDataSource implements CompetitionDataSource {
  final SupabaseClient _client;

  CompetitionRemoteDataSource(this._client);

  SupabaseQueryBuilder get _table => _client.from(AppConstants.tableCompetitions);

  @override
  Future<List<CompetitionModel>> getCompetitions() async {
    final data = await _table.select().order('name', ascending: true);
    printer(' ----> ${AppConstants.tableCompetitions}  : $data');
    return (data as List)
        .map((e) => CompetitionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CompetitionModel> createCompetition(CompetitionModel competition) async {
    final data =
        await _table.insert(competition.toWriteMap()).select().single();
    return CompetitionModel.fromJson(data);
  }

  @override
  Future<CompetitionModel> updateCompetition(
      int id, CompetitionModel competition) async {
    final data = await _table
        .update(competition.toWriteMap())
        .eq('id', id)
        .select()
        .single();
    return CompetitionModel.fromJson(data);
  }

  @override
  Future<void> deleteCompetition(int id) async {
    await _table.delete().eq('id', id);
  }
}
