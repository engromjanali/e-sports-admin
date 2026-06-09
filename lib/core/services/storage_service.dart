import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:supabase/supabase.dart';

import '../../config/util/app_constants.dart';

/// Handles file uploads to Supabase Storage and returns public URLs.
@lazySingleton
class StorageService {
  final SupabaseClient _client;

  StorageService(this._client);

  /// Uploads [bytes] to [folder] inside the configured bucket and returns the
  /// public URL. [fileExtension] should be without a dot (e.g. `jpg`).
  Future<String> uploadImage({
    required Uint8List bytes,
    required String folder,
    required String fileExtension,
    String? contentType,
  }) async {
    final safeExt = fileExtension.replaceAll('.', '').toLowerCase();
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final path = '$folder/$timestamp.$safeExt';

    final bucket = _client.storage.from(AppConstants.storageBucket);

    await bucket.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        upsert: true,
        contentType: contentType ?? 'image/$safeExt',
      ),
    );

    return bucket.getPublicUrl(path);
  }
}
