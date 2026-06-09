import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/usecases/player_usecases.dart';

// ----------------------------- Events -----------------------------
sealed class PlayerEvent extends Equatable {
  const PlayerEvent();
  @override
  List<Object?> get props => [];
}

class LoadPlayers extends PlayerEvent {
  const LoadPlayers();
}

class CreatePlayerRequested extends PlayerEvent {
  final PlayerEntity player;
  const CreatePlayerRequested(this.player);
  @override
  List<Object?> get props => [player];
}

class UpdatePlayerRequested extends PlayerEvent {
  final PlayerEntity player;
  const UpdatePlayerRequested(this.player);
  @override
  List<Object?> get props => [player];
}

class DeletePlayerRequested extends PlayerEvent {
  final String id;
  const DeletePlayerRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class ClearPlayerFeedback extends PlayerEvent {
  const ClearPlayerFeedback();
}

// ----------------------------- State -----------------------------
enum PlayerStatus { initial, loading, success, failure }

class PlayerState extends Equatable {
  final PlayerStatus status;
  final List<PlayerEntity> players;
  final String? errorMessage;
  final bool isSubmitting;
  final String? actionMessage;
  final String? actionError;

  const PlayerState({
    this.status = PlayerStatus.initial,
    this.players = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.actionMessage,
    this.actionError,
  });

  PlayerState copyWith({
    PlayerStatus? status,
    List<PlayerEntity>? players,
    String? errorMessage,
    bool? isSubmitting,
    String? actionMessage,
    String? actionError,
    bool clearFeedback = false,
  }) {
    return PlayerState(
      status: status ?? this.status,
      players: players ?? this.players,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionMessage: clearFeedback ? null : (actionMessage ?? this.actionMessage),
      actionError: clearFeedback ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props =>
      [status, players, errorMessage, isSubmitting, actionMessage, actionError];
}

// ----------------------------- Bloc -----------------------------
@injectable
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final GetPlayersUseCase _getPlayers;
  final CreatePlayerUseCase _createPlayer;
  final UpdatePlayerUseCase _updatePlayer;
  final DeletePlayerUseCase _deletePlayer;

  PlayerBloc(
    this._getPlayers,
    this._createPlayer,
    this._updatePlayer,
    this._deletePlayer,
  ) : super(const PlayerState()) {
    on<LoadPlayers>(_onLoad);
    on<CreatePlayerRequested>(_onCreate);
    on<UpdatePlayerRequested>(_onUpdate);
    on<DeletePlayerRequested>(_onDelete);
    on<ClearPlayerFeedback>(
      (_, emit) => emit(state.copyWith(clearFeedback: true)),
    );
  }

  Future<void> _onLoad(LoadPlayers event, Emitter<PlayerState> emit) async {
    emit(state.copyWith(status: PlayerStatus.loading));
    final result = await _getPlayers(const NoParams());
    result.when(
      success: (s) =>
          emit(state.copyWith(status: PlayerStatus.success, players: s.data)),
      failure: (f) => emit(
        state.copyWith(
          status: PlayerStatus.failure,
          errorMessage: f.error.toString(),
        ),
      ),
    );
  }

  Future<void> _onCreate(
    CreatePlayerRequested event,
    Emitter<PlayerState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));
    final result = await _createPlayer(event.player);
    await result.when(
      success: (_) async {
        emit(state.copyWith(isSubmitting: false, actionMessage: 'Player added'));
        add(const LoadPlayers());
      },
      failure: (f) async => emit(
        state.copyWith(isSubmitting: false, actionError: f.error.toString()),
      ),
    );
  }

  Future<void> _onUpdate(
    UpdatePlayerRequested event,
    Emitter<PlayerState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));
    final result = await _updatePlayer(event.player);
    await result.when(
      success: (_) async {
        emit(state.copyWith(isSubmitting: false, actionMessage: 'Player updated'));
        add(const LoadPlayers());
      },
      failure: (f) async => emit(
        state.copyWith(isSubmitting: false, actionError: f.error.toString()),
      ),
    );
  }

  Future<void> _onDelete(
    DeletePlayerRequested event,
    Emitter<PlayerState> emit,
  ) async {
    final result = await _deletePlayer(event.id);
    result.when(
      success: (_) {
        emit(state.copyWith(actionMessage: 'Player deleted'));
        add(const LoadPlayers());
      },
      failure: (f) => emit(state.copyWith(actionError: f.error.toString())),
    );
  }
}
