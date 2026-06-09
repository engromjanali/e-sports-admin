import 'package:injectable/injectable.dart';
import 'package:supabase/supabase.dart';

import '../../config/util/app_constants.dart';

/// Provides the [SupabaseClient] used for all admin data entry and storage.
///
/// The admin panel talks to Supabase directly (Postgrest + Storage), mirroring
/// the consumer app. Auth/config still use the Dio [ApiClient].
@module
abstract class SupabaseModule {
  @lazySingleton
  SupabaseClient get supabaseClient => SupabaseClient(
        AppConstants.supabaseUrl,
        AppConstants.supabaseAnonKey,
      );
}
