import 'package:injectable/injectable.dart';
import '../../models/user_model.dart';
import '../interfaces/auth_data_source.dart';
import 'auth_api_service.dart';

/// Remote data source implementation for authentication
@LazySingleton(as: AuthDataSource)
class AuthRemoteDataSourceImpl implements AuthDataSource {
  final AuthApiService _apiService;

  AuthRemoteDataSourceImpl(this._apiService);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final user = await _apiService.login({
      'email': email,
      'password': password,
    });
    return user;
  }

  @override
  Future<void> logout() async {
    await _apiService.logout();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = await _apiService.getCurrentUser();
    return user;
  }
}
