part of 'localization_bloc.dart';

@Freezed(toJson: false, fromJson: false)
class LocalizationEvent with _$LocalizationEvent {
  /// Load the saved locale
  const factory LocalizationEvent.loadLocale() = _LoadLocale;

  /// Change to a new locale
  const factory LocalizationEvent.changeLocale(String localeCode) = _ChangeLocale;
}
