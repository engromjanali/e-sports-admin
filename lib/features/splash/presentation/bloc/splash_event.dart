part of 'splash_bloc.dart';

@Freezed(toJson: false, fromJson: false)
class SplashEvent with _$SplashEvent {
  const factory SplashEvent.getConfig() = _GetConfig;
}
