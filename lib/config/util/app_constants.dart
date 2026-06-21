import '../../features/settings/domain/entities/language_model.dart';

/// Application-level constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Clean Boilerplate';
  static const String appVersion = '1.0.0';

  // API constants (Update with your actual API URLs)
  static const String baseUrl = 'https://foatball.vercel.app';

  // ------------------ Supabase ------------------
  // Direct Supabase client is used for all admin data entry + storage.
  static const String supabaseUrl = 'https://ttietyuwaamuiziwzmst.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0aWV0eXV3YWFtdWl6aXd6bXN0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNjYyNzIsImV4cCI6MjA5Njk0MjI3Mn0.9fDKu8rn7edXyPu1LpGuP2M7ocM6gkD1KiHTTZHKWYs';

  // Supabase storage bucket used for admin uploads (player photos, news images).
  // NOTE: create a public bucket with this name in the Supabase dashboard.
  static const String storageBucket = 'media';
  static const String playersImageFolder = 'players';
  static const String newsImageFolder = 'news';

  // ------------------ Supabase tables ------------------
  static const String tableSeason = 'season';
  static const String tablePlayers = 'players';
  static const String tableMatches = 'matches';
  static const String tableMatchEntries = 'match_entries';
  static const String tablePlayerSeasonStats = 'player_season_stats';
  static const String tableAwards = 'awards';
  static const String tableNews = 'news';
  static const String tableAppSettings = 'app_settings';
  static const String tableFaqs = 'faqs';
  static const String tablePrivacyPolicy = 'privacy_policy';
  static const String tableCompetitions = 'competitions';
  static const String tableHallOfFame = 'hall_of_fame';

  // ------------------ API endpoints-------------
  // auth
  static const String configEndPoint = '/api/v1/config';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String profileEndpoint = '/user/profile';

  // business setup
  static const String businessSetupUri = 'api/admin/business-setup';




  static const String tokenKey = 'auth_token';
  static const String guestUserIdKey = 'guest_user_id';
  static const String languageCodeKey = 'language_code';
  static const String defaultLanguageCode = 'en';

  // Pagination
  static const int paginationLimit = 20;
  static const int paginationLimitSmall = 10;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;

  // Timeouts (in seconds)
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // Error messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unknownErrorMessage = 'An unknown error occurred.';
  static const String validationErrorMessage = 'Please check your input and try again.';


  static final List<LanguageModel> languages = [
    LanguageModel(
      code: 'bn',
      name: 'Bangla',
      nativeName: 'বাংলা',
    ),

    LanguageModel(
      code: 'en',
      name: 'English',
      nativeName: 'English',
    ),

    LanguageModel(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
    ),
  ];
}
