import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../player/domain/entities/player_entity.dart';
import '../../../player/domain/usecases/player_usecases.dart';
import '../../domain/entities/hall_of_fame_entity.dart';
import '../../domain/usecases/hall_of_fame_usecases.dart';

// ----------------------------- Events -----------------------------
sealed class HallOfFameEvent extends Equatable {
  const HallOfFameEvent();
  @override
  List<Object?> get props => [];
}

class LoadHallOfFame extends HallOfFameEvent {
  const LoadHallOfFame();
}

class CreateHallOfFameRequested extends HallOfFameEvent {
  final HallOfFameEntity entry;
  const CreateHallOfFameRequested(this.entry);
  @override
  List<Object?> get props => [entry];
}

class UpdateHallOfFameRequested extends HallOfFameEvent {
  final HallOfFameEntity entry;
  const UpdateHallOfFameRequested(this.entry);
  @override
  List<Object?> get props => [entry];
}

class DeleteHallOfFameRequested extends HallOfFameEvent {
  final String id;
  const DeleteHallOfFameRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class ClearHallOfFameFeedback extends HallOfFameEvent {
  const ClearHallOfFameFeedback();
}

// ----------------------------- State -----------------------------
enum HallOfFameStatus { initial, loading, success, failure }

class HallOfFameState extends Equatable {
  final HallOfFameStatus status;
  final List<HallOfFameEntity> entries;
  final List<PlayerEntity> players;
  final String? errorMessage;
  final bool isSubmitting;
  final String? actionMessage;
  final String? actionError;

  const HallOfFameState({
    this.status = HallOfFameStatus.initial,
    this.entries = const [],
    this.players = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.actionMessage,
    this.actionError,
  });

  /// Entries grouped by category, preserving the loaded (sorted) order.
  Map<HofCategory, List<HallOfFameEntity>> get grouped {
    final map = <HofCategory, List<HallOfFameEntity>>{
      for (final c in HofCategory.values) c: [],
    };
    for (final e in entries) {
      map[e.category]!.add(e);
    }
    return map;
  }

  HallOfFameState copyWith({
    HallOfFameStatus? status,
    List<HallOfFameEntity>? entries,
    List<PlayerEntity>? players,
    String? errorMessage,
    bool? isSubmitting,
    String? actionMessage,
    String? actionError,
    bool clearFeedback = false,
  }) {
    return HallOfFameState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      players: players ?? this.players,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionMessage:
          clearFeedback ? null : (actionMessage ?? this.actionMessage),
      actionError: clearFeedback ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        entries,
        players,
        errorMessage,
        isSubmitting,
        actionMessage,
        actionError,
      ];
}

// ----------------------------- Bloc -----------------------------
@injectable
class HallOfFameBloc extends Bloc<HallOfFameEvent, HallOfFameState> {
  final GetHallOfFameUseCase _getEntries;
  final CreateHallOfFameUseCase _createEntry;
  final UpdateHallOfFameUseCase _updateEntry;
  final DeleteHallOfFameUseCase _deleteEntry;
  final GetPlayersUseCase _getPlayers;

  HallOfFameBloc(
    this._getEntries,
    this._createEntry,
    this._updateEntry,
    this._deleteEntry,
    this._getPlayers,
  ) : super(const HallOfFameState()) {
    on<LoadHallOfFame>(_onLoad);
    on<CreateHallOfFameRequested>(_onCreate);
    on<UpdateHallOfFameRequested>(_onUpdate);
    on<DeleteHallOfFameRequested>(_onDelete);
    on<ClearHallOfFameFeedback>(
      (_, emit) => emit(state.copyWith(clearFeedback: true)),
    );
  }

  Future<void> _onLoad(
    LoadHallOfFame event,
    Emitter<HallOfFameState> emit,
  ) async {
    emit(state.copyWith(status: HallOfFameStatus.loading));

    // Players are loaded alongside entries to feed the form's player picker;
    // a player-load failure shouldn't block the list, so it's handled softly.
    final playersResult = await _getPlayers(const NoParams());
    final players = playersResult.data ?? state.players;

    final result = await _getEntries(const NoParams());
    result.when(
      success: (s) => emit(state.copyWith(
        status: HallOfFameStatus.success,
        entries: s.data,
        players: players,
      )),
      failure: (f) => emit(state.copyWith(
        status: HallOfFameStatus.failure,
        players: players,
        errorMessage: f.error.toString(),
      )),
    );
  }

  Future<void> _onCreate(
    CreateHallOfFameRequested event,
    Emitter<HallOfFameState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));
    final result = await _createEntry(event.entry);
    await result.when(
      success: (_) async {
        emit(state.copyWith(
            isSubmitting: false, actionMessage: 'Inductee added'));
        add(const LoadHallOfFame());
      },
      failure: (f) async => emit(
        state.copyWith(isSubmitting: false, actionError: f.error.toString()),
      ),
    );
  }

  Future<void> _onUpdate(
    UpdateHallOfFameRequested event,
    Emitter<HallOfFameState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));
    final result = await _updateEntry(event.entry);
    await result.when(
      success: (_) async {
        emit(state.copyWith(
            isSubmitting: false, actionMessage: 'Inductee updated'));
        add(const LoadHallOfFame());
      },
      failure: (f) async => emit(
        state.copyWith(isSubmitting: false, actionError: f.error.toString()),
      ),
    );
  }

  Future<void> _onDelete(
    DeleteHallOfFameRequested event,
    Emitter<HallOfFameState> emit,
  ) async {
    final result = await _deleteEntry(event.id);
    result.when(
      success: (_) {
        emit(state.copyWith(actionMessage: 'Inductee deleted'));
        add(const LoadHallOfFame());
      },
      failure: (f) => emit(state.copyWith(actionError: f.error.toString())),
    );
  }
}
