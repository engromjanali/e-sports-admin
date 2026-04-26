part of 'theme_bloc.dart';

/// Theme state - simple dark/light representation
@Freezed(toJson: false, fromJson: false)
class ThemeState with _$ThemeState {
  /// Dark theme state
  const factory ThemeState.dark({@Default(false) bool value}) = _Dark;

  /// Light theme state
  const factory ThemeState.light({@Default(true) bool value}) = _Light;

  /// Private constructor for custom methods
  const ThemeState._();

  /// Override value getter to extract boolean from both states
  @override
  bool get value => when(dark: (value) => value, light: (value) => value);
}
