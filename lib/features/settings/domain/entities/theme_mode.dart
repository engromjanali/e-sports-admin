/// Theme mode options for the app
enum AppThemeMode {
  /// Light theme
  light,

  /// Dark theme
  dark,
}

/// Extension methods for AppThemeMode
extension AppThemeModeExtension on AppThemeMode {
  /// Convert enum to string for storage
  String toStringValue() {
    switch (this) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
    }
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }
}

/// Extension to convert string to AppThemeMode
extension StringToAppThemeMode on String {
  /// Parse string to AppThemeMode
  AppThemeMode toAppThemeMode() {
    switch (toLowerCase()) {
      case 'dark':
        return AppThemeMode.dark;
      case 'light':
      default:
        return AppThemeMode.light;
    }
  }
}
