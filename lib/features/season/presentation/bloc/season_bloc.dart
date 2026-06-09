import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/season_entity.dart';
import '../../domain/usecases/season_usecases.dart';

// ----------------------------- Events -----------------------------
sealed class SeasonEvent extends Equatable {
  const SeasonEvent();
  @override
  List<Object?> get props => [];
}

class LoadSeasons extends SeasonEvent {
  const LoadSeasons();
}

class CreateSeasonRequested extends SeasonEvent {
  final SeasonEntity season;
  const CreateSeasonRequested(this.season);
  @override
  List<Object?> get props => [season];
}

class UpdateSeasonRequested extends SeasonEvent {
  final SeasonEntity season;
  const UpdateSeasonRequested(this.season);
  @override
  List<Object?> get props => [season];
}

class DeleteSeasonRequested extends SeasonEvent {
  final int id;
  const DeleteSeasonRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class SetCurrentSeasonRequested extends SeasonEvent {
  final int id;
  const SetCurrentSeasonRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class ClearSeasonFeedback extends SeasonEvent {
  const ClearSeasonFeedback();
}

// ----------------------------- State -----------------------------
enum SeasonStatus { initial, loading, success, failure }

class SeasonState extends Equatable {
  final SeasonStatus status;
  final List<SeasonEntity> seasons;
  final String? errorMessage;
  final bool isSubmitting;
  final String? actionMessage;
  final String? actionError;

  const SeasonState({
    this.status = SeasonStatus.initial,
    this.seasons = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.actionMessage,
    this.actionError,
  });

  SeasonState copyWith({
    SeasonStatus? status,
    List<SeasonEntity>? seasons,
    String? errorMessage,
    bool? isSubmitting,
    String? actionMessage,
    String? actionError,
    bool clearFeedback = false,
  }) {
    return SeasonState(
      status: status ?? this.status,
      seasons: seasons ?? this.seasons,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionMessage: clearFeedback ? null : (actionMessage ?? this.actionMessage),
      actionError: clearFeedback ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props =>
      [status, seasons, errorMessage, isSubmitting, actionMessage, actionError];
}

// ----------------------------- Bloc -----------------------------
@injectable
class SeasonBloc extends Bloc<SeasonEvent, SeasonState> {
  final GetSeasonsUseCase _getSeasons;
  final CreateSeasonUseCase _createSeason;
  final UpdateSeasonUseCase _updateSeason;
  final DeleteSeasonUseCase _deleteSeason;
  final SetCurrentSeasonUseCase _setCurrent;

  SeasonBloc(
    this._getSeasons,
    this._createSeason,
    this._updateSeason,
    this._deleteSeason,
    this._setCurrent,
  ) : super(const SeasonState()) {
    on<LoadSeasons>(_onLoad);
    on<CreateSeasonRequested>(_onCreate);
    on<UpdateSeasonRequested>(_onUpdate);
    on<DeleteSeasonRequested>(_onDelete);
    on<SetCurrentSeasonRequested>(_onSetCurrent);
    on<ClearSeasonFeedback>(
      (_, emit) => emit(state.copyWith(clearFeedback: true)),
    );
  }

  Future<void> _onLoad(LoadSeasons event, Emitter<SeasonState> emit) async {
    emit(state.copyWith(status: SeasonStatus.loading));
    final result = await _getSeasons(const NoParams());
    result.when(
      success: (s) => emit(
        state.copyWith(status: SeasonStatus.success, seasons: s.data),
      ),
      failure: (f) => emit(
        state.copyWith(
          status: SeasonStatus.failure,
          errorMessage: f.error.toString(),
        ),
      ),
    );
  }

  Future<void> _onCreate(
    CreateSeasonRequested event,
    Emitter<SeasonState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));
    final result = await _createSeason(event.season);
    await result.when(
      success: (_) async {
        emit(state.copyWith(isSubmitting: false, actionMessage: 'Season created'));
        add(const LoadSeasons());
      },
      failure: (f) async => emit(
        state.copyWith(isSubmitting: false, actionError: f.error.toString()),
      ),
    );
  }

  Future<void> _onUpdate(
    UpdateSeasonRequested event,
    Emitter<SeasonState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));
    final result = await _updateSeason(event.season);
    await result.when(
      success: (_) async {
        emit(state.copyWith(isSubmitting: false, actionMessage: 'Season updated'));
        add(const LoadSeasons());
      },
      failure: (f) async => emit(
        state.copyWith(isSubmitting: false, actionError: f.error.toString()),
      ),
    );
  }

  Future<void> _onDelete(
    DeleteSeasonRequested event,
    Emitter<SeasonState> emit,
  ) async {
    final result = await _deleteSeason(event.id);
    result.when(
      success: (_) {
        emit(state.copyWith(actionMessage: 'Season deleted'));
        add(const LoadSeasons());
      },
      failure: (f) =>
          emit(state.copyWith(actionError: f.error.toString())),
    );
  }

  Future<void> _onSetCurrent(
    SetCurrentSeasonRequested event,
    Emitter<SeasonState> emit,
  ) async {
    final result = await _setCurrent(event.id);
    result.when(
      success: (_) {
        emit(state.copyWith(actionMessage: 'Current season updated'));
        add(const LoadSeasons());
      },
      failure: (f) =>
          emit(state.copyWith(actionError: f.error.toString())),
    );
  }
}
