import 'package:clean_boilerplate/config/util/app_constants.dart';
import 'package:clean_boilerplate/core/network/api_client.dart';
import 'package:clean_boilerplate/features/auth/data/models/user_model.dart';

/// Auth API service using ApiClient
class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  Future<UserModel> login(Map<String, dynamic> body) async {
    final response = await _apiClient.post(AppConstants.loginEndpoint, data: body);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _apiClient.post(AppConstants.logoutEndpoint);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(AppConstants.profileEndpoint);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
