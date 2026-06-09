import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../season/domain/entities/season_entity.dart';
import '../../../season/domain/usecases/season_usecases.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/usecases/match_usecases.dart';

// ----------------------------- Events -----------------------------
sealed class MatchEvent extends Equatable {
  const MatchEvent();
  @override
  List<Object?> get props => [];
}

class InitMatchData extends MatchEvent {
  const InitMatchData();
}

class SelectMatchSeason extends MatchEvent {
  final int seasonId;
  const SelectMatchSeason(this.seasonId);
  @override
  List<Object?> get props => [seasonId];
}

class CreateMatchRequested extends MatchEvent {
  final MatchEntity match;
  const CreateMatchRequested(this.match);
  @override
  List<Object?> get props => [match];
}

class UpdateMatchRequested extends MatchEvent {
  final MatchEntity match;
  const UpdateMatchRequested(this.match);
  @override
  List<Object?> get props => [match];
}

class DeleteMatchRequested extends MatchEvent {
  final String id;
  const DeleteMatchRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class ClearMatchFeedback extends MatchEvent {
  const ClearMatchFeedback();
}

// ----------------------------- State -----------------------------
enum MatchListStatus { initial, loading, success, failure }

class MatchState extends Equatable {
  final MatchListStatus status;
  final List<SeasonEntity> seasons;
  final int? selectedSeasonId;
  final List<MatchEntity> matches;
  final String? errorMessage;
  final bool isSubmitting;
  final String? actionMessage;
  final String? actionError;

  const MatchState({
    this.status = MatchListStatus.initial,
    this.seasons = const [],
    this.selectedSeasonId,
    this.matches = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.actionMessage,
    this.actionError,
  });

  MatchState copyWith({
    MatchListStatus? status,
    List<SeasonEntity>? seasons,
    int? selectedSeasonId,
    List<MatchEntity>? matches,
    String? errorMessage,
    bool? isSubmitting,
    String? actionMessage,
    String? actionError,
    bool clearFeedback = false,
  }) {
    return MatchState(
      status: status ?? this.status,
      seasons: seasons ?? this.seasons,
      selectedSeasonId: selectedSeasonId ?? this.selectedSeasonId,
      matches: matches ?? this.matches,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionMessage: clearFeedback ? null : (actionMessage ?? this.actionMessage),
      actionError: clearFeedback ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        seasons,
        selectedSeasonId,
        matches,
        errorMessage,
        isSubmitting,
        actionMessage,
        actionError,
      ];
}

// ----------------------------- Bloc -----------------------------
@injectable
class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final GetSeasonsUseCase _getSeasons;
  final GetMatchesUseCase _getMatches;
  final CreateMatchUseCase _createMatch;
  final UpdateMatchUseCase _updateMatch;
  final DeleteMatchUseCase _deleteMatch;

  MatchBloc(
    this._getSeasons,
    this._getMatches,
    this._createMatch,
    this._updateMatch,
    this._deleteMatch,
  ) : super(const MatchState()) {
    on<InitMatchData>(_onInit);
    on<SelectMatchSeason>(_onSelectSeason);
    on<CreateMatchRequested>(_onCreate);
    on<UpdateMatchRequested>(_onUpdate);
    on<DeleteMatchRequested>(_onDelete);
    on<ClearMatchFeedback>(
      (_, emit) => emit(state.copyWith(clearFeedback: true)),
    );
  }

  Future<void> _onInit(InitMatchData event, Emitter<MatchState> emit) async {
    emit(state.copyWith(status: MatchListStatus.loading));
    final seasonResult = await _getSeasons(const NoParams());

    final seasons = seasonResult.data;
    if (seasonResult.isFailure || seasons == null) {
      emit(state.copyWith(
        status: MatchListStatus.failure,
        errorMessage: seasonResult.error?.toString(),
      ));
      return;
    }

    final selected = seasons.isEmpty
        ? null
        : seasons
            .firstWhere((s) => s.isCurrent, orElse: () => seasons.first)
            .id;

    emit(state.copyWith(seasons: seasons, selectedSeasonId: selected));
    await _loadMatches(selected, emit);
  }

  Future<void> _onSelectSeason(
    SelectMatchSeason event,
    Emitter<MatchState> emit,
  ) async {
    emit(state.copyWith(selectedSeasonId: event.seasonId));
    await _loadMatches(event.seasonId, emit);
  }

  Future<void> _loadMatches(int? seasonId, Emitter<MatchState> emit) async {
    emit(state.copyWith(status: MatchListStatus.loading));
    final result = await _getMatches(GetMatchesParams(seasonId: seasonId));
    result.when(
      success: (s) =>
          emit(state.copyWith(status: MatchListStatus.success, matches: s.data)),
      failure: (f) => emit(state.copyWith(
        status: MatchListStatus.failure,
        errorMessage: f.error.toString(),
      )),
    );
  }

  Future<void> _onCreate(
    CreateMatchRequested event,
    Emitter<MatchState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));
    final result = await _createMatch(event.match);
    await result.when(
      success: (_) async {
        emit(state.copyWith(isSubmitting: false, actionMessage: 'Match created'));
        await _loadMatches(state.selectedSeasonId, emit);
      },
      failure: (f) async => emit(
        state.copyWith(isSubmitting: false, actionError: f.error.toString()),
      ),
    );
  }

  Future<void> _onUpdate(
    UpdateMatchRequested event,
    Emitter<MatchState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));
    final result = await _updateMatch(event.match);
    await result.when(
      success: (_) async {
        emit(state.copyWith(isSubmitting: false, actionMessage: 'Match updated'));
        await _loadMatches(state.selectedSeasonId, emit);
      },
      failure: (f) async => emit(
        state.copyWith(isSubmitting: false, actionError: f.error.toString()),
      ),
    );
  }

  Future<void> _onDelete(
    DeleteMatchRequested event,
    Emitter<MatchState> emit,
  ) async {
    final result = await _deleteMatch(event.id);
    await result.when(
      success: (_) async {
        emit(state.copyWith(actionMessage: 'Match deleted'));
        await _loadMatches(state.selectedSeasonId, emit);
      },
      failure: (f) async =>
          emit(state.copyWith(actionError: f.error.toString())),
    );
  }
}
