import 'package:clean_boilerplate/core/network/api_client.dart';
import 'package:clean_boilerplate/features/auth/data/models/user_model.dart';

/// Auth API service using ApiClient
class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  Future<UserModel> login(Map<String, dynamic> body) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: body,
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get('/auth/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
