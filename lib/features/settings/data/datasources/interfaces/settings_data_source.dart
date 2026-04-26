/// Settings data source interface (abstraction in data layer)
abstract class SettingsDataSource {
  /// Get the current theme mode as a string
  Future<String> getThemeMode();

  /// Save the theme mode
  Future<void> saveThemeMode(String mode);

  /// Get the current locale code
  Future<String> getLocale();

  /// Save locale code
  Future<void> saveLocale(String localeCode);
}
