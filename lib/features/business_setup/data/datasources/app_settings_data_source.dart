import 'package:injectable/injectable.dart';
import 'package:supabase/supabase.dart';

import '../../../../config/util/app_constants.dart';
import '../models/app_settings_model.dart';

abstract class AppSettingsDataSource {
  Future<AppSettingsModel> getSettings();
  Future<AppSettingsModel> updateSettings(AppSettingsModel settings);
}

@LazySingleton(as: AppSettingsDataSource)
class AppSettingsRemoteDataSource implements AppSettingsDataSource {
  final SupabaseClient _client;

  AppSettingsRemoteDataSource(this._client);

  SupabaseQueryBuilder get _table =>
      _client.from(AppConstants.tableAppSettings);

  @override
  Future<AppSettingsModel> getSettings() async {
    final data =
        await _table.select().order('id', ascending: true).limit(1).single();
    return AppSettingsModel.fromJson(data);
  }

  @override
  Future<AppSettingsModel> updateSettings(AppSettingsModel settings) async {
    final data = await _table
        .update(settings.toUpdateMap())
        .eq('id', settings.id)
        .select()
        .single();
    return AppSettingsModel.fromJson(data);
  }
}
