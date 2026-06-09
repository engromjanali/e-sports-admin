import 'package:supabase/supabase.dart';

import '../../config/util/result.dart';
import '../errors/failures.dart';

/// Wraps a Supabase call that returns a value, converting any thrown
/// exception into a [Result.failure] with the appropriate failure type.
///
/// Keeps repository implementations free of repetitive try/catch blocks.
Future<Result<T>> guardSupabase<T>(Future<T> Function() action) async {
  try {
    return Result.success(data: await action());
  } catch (e) {
    return _toFailure<T>(e);
  }
}

/// Same as [guardSupabase] but for void operations (delete, etc.).
Future<Result<void>> guardSupabaseVoid(
  Future<void> Function() action,
) async {
  try {
    await action();
    return Result.success(data: null);
  } catch (e) {
    return _toFailure<void>(e);
  }
}

Result<T> _toFailure<T>(Object e) {
  if (e is PostgrestException) {
    return Result.failure(
      error: ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      ),
      message: e.message,
    );
  }
  if (e is StorageException) {
    return Result.failure(
      error: ServerFailure(
        message: e.message,
        statusCode: int.tryParse(e.statusCode ?? ''),
      ),
      message: e.message,
    );
  }
  if (e is AuthException) {
    return Result.failure(
      error: AuthenticationFailure(message: e.message),
      message: e.message,
    );
  }
  return Result.failure(
    error: ServerFailure(message: e.toString()),
    message: e.toString(),
  );
}
