import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../season/domain/entities/season_entity.dart';
import '../../../season/domain/usecases/season_usecases.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/usecases/app_settings_usecases.dart';

// ----------------------------- Events -----------------------------
sealed class BusinessSetupEvent extends Equatable {
  const BusinessSetupEvent();
  @override
  List<Object?> get props => [];
}

class LoadBusinessSetup extends BusinessSetupEvent {
  const LoadBusinessSetup();
}

class SaveBusinessSetup extends BusinessSetupEvent {
  final AppSettingsEntity settings;
  const SaveBusinessSetup(this.settings);
  @override
  List<Object?> get props => [settings];
}

class ClearBusinessSetupFeedback extends BusinessSetupEvent {
  const ClearBusinessSetupFeedback();
}

// ----------------------------- State -----------------------------
enum BusinessSetupStatus { initial, loading, success, failure }

class BusinessSetupState extends Equatable {
  final BusinessSetupStatus status;
  final AppSettingsEntity? settings;
  final List<SeasonEntity> seasons;
  final String? errorMessage;
  final bool isSaving;
  final String? actionMessage;
  final String? actionError;

  const BusinessSetupState({
    this.status = BusinessSetupStatus.initial,
    this.settings,
    this.seasons = const [],
    this.errorMessage,
    this.isSaving = false,
    this.actionMessage,
    this.actionError,
  });

  BusinessSetupState copyWith({
    BusinessSetupStatus? status,
    AppSettingsEntity? settings,
    List<SeasonEntity>? seasons,
    String? errorMessage,
    bool? isSaving,
    String? actionMessage,
    String? actionError,
    bool clearFeedback = false,
  }) {
    return BusinessSetupState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      seasons: seasons ?? this.seasons,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
      actionMessage: clearFeedback ? null : (actionMessage ?? this.actionMessage),
      actionError: clearFeedback ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        settings,
        seasons,
        errorMessage,
        isSaving,
        actionMessage,
        actionError,
      ];
}

// ----------------------------- Bloc -----------------------------
@injectable
class BusinessSetupBloc extends Bloc<BusinessSetupEvent, BusinessSetupState> {
  final GetAppSettingsUseCase _getSettings;
  final UpdateAppSettingsUseCase _updateSettings;
  final GetSeasonsUseCase _getSeasons;

  BusinessSetupBloc(
    this._getSettings,
    this._updateSettings,
    this._getSeasons,
  ) : super(const BusinessSetupState()) {
    on<LoadBusinessSetup>(_onLoad);
    on<SaveBusinessSetup>(_onSave);
    on<ClearBusinessSetupFeedback>(
      (_, emit) => emit(state.copyWith(clearFeedback: true)),
    );
  }

  Future<void> _onLoad(
    LoadBusinessSetup event,
    Emitter<BusinessSetupState> emit,
  ) async {
    emit(state.copyWith(status: BusinessSetupStatus.loading));

    final seasonsResult = await _getSeasons(const NoParams());
    final settingsResult = await _getSettings(const NoParams());

    if (settingsResult.isFailure) {
      emit(state.copyWith(
        status: BusinessSetupStatus.failure,
        errorMessage: settingsResult.error?.toString(),
      ));
      return;
    }

    emit(state.copyWith(
      status: BusinessSetupStatus.success,
      settings: settingsResult.data,
      seasons: seasonsResult.data ?? const [],
    ));
  }

  Future<void> _onSave(
    SaveBusinessSetup event,
    Emitter<BusinessSetupState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearFeedback: true));
    final result = await _updateSettings(event.settings);
    result.when(
      success: (s) => emit(state.copyWith(
        isSaving: false,
        settings: s.data,
        actionMessage: 'Settings saved',
      )),
      failure: (f) => emit(state.copyWith(
        isSaving: false,
        actionError: f.error.toString(),
      )),
    );
  }
}
