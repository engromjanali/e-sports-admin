import 'package:injectable/injectable.dart';
import '../network/api_client.dart';
import '../../features/auth/data/datasources/remote/auth_api_service.dart';

/// Data source module for dependency injection
@module
abstract class DataSourceModule {
  @lazySingleton
  AuthApiService authApiService(ApiClient apiClient) => 
      AuthApiService(apiClient);
}
