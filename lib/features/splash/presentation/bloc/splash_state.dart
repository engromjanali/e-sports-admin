part of 'splash_bloc.dart';

@Freezed(toJson: false, fromJson: false)
class SplashState with _$SplashState {
  const factory SplashState.loading() = _Loading;
  const factory SplashState.loaded(ConfigEntity config) = _Loaded;
  const factory SplashState.error(String error) = _Error;
}
