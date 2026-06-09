import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../player/domain/entities/player_entity.dart';
import '../../../player/domain/usecases/player_usecases.dart';
import '../../domain/entities/match_entry_entity.dart';
import '../../domain/usecases/match_entry_usecases.dart';

// ----------------------------- Events -----------------------------
sealed class MatchEntryEvent extends Equatable {
  const MatchEntryEvent();
  @override
  List<Object?> get props => [];
}

class InitMatchEntries extends MatchEntryEvent {
  final String matchId;
  const InitMatchEntries(this.matchId);
  @override
  List<Object?> get props => [matchId];
}

class ReloadMatchEntries extends MatchEntryEvent {
  const ReloadMatchEntries();
}

class UpsertMatchEntryRequested extends MatchEntryEvent {
  final MatchEntryEntity entry;
  const UpsertMatchEntryRequested(this.entry);
  @override
  List<Object?> get props => [entry];
}

class DeleteMatchEntryRequested extends MatchEntryEvent {
  final String id;
  const DeleteMatchEntryRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class ClearMatchEntryFeedback extends MatchEntryEvent {
  const ClearMatchEntryFeedback();
}

// ----------------------------- State -----------------------------
enum MatchEntryStatus { initial, loading, success, failure }

class MatchEntryState extends Equatable {
  final MatchEntryStatus status;
  final String matchId;
  final List<MatchEntryEntity> entries;
  final List<PlayerEntity> allPlayers;
  final String? errorMessage;
  final bool isSubmitting;
  final String? actionMessage;
  final String? actionError;

  const MatchEntryState({
    this.status = MatchEntryStatus.initial,
    this.matchId = '',
    this.entries = const [],
    this.allPlayers = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.actionMessage,
    this.actionError,
  });

  /// Players that don't yet have an entry for this match.
  List<PlayerEntity> get availablePlayers {
    final usedIds = entries.map((e) => e.playerId).toSet();
    return allPlayers.where((p) => !usedIds.contains(p.id)).toList();
  }

  MatchEntryState copyWith({
    MatchEntryStatus? status,
    String? matchId,
    List<MatchEntryEntity>? entries,
    List<PlayerEntity>? allPlayers,
    String? errorMessage,
    bool? isSubmitting,
    String? actionMessage,
    String? actionError,
    bool clearFeedback = false,
  }) {
    return MatchEntryState(
      status: status ?? this.status,
      matchId: matchId ?? this.matchId,
      entries: entries ?? this.entries,
      allPlayers: allPlayers ?? this.allPlayers,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionMessage: clearFeedback ? null : (actionMessage ?? this.actionMessage),
      actionError: clearFeedback ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        matchId,
        entries,
        allPlayers,
        errorMessage,
        isSubmitting,
        actionMessage,
        actionError,
      ];
}

// ----------------------------- Bloc -----------------------------
@injectable
class MatchEntryBloc extends Bloc<MatchEntryEvent, MatchEntryState> {
  final GetMatchEntriesUseCase _getEntries;
  final UpsertMatchEntryUseCase _upsertEntry;
  final DeleteMatchEntryUseCase _deleteEntry;
  final GetPlayersUseCase _getPlayers;

  MatchEntryBloc(
    this._getEntries,
    this._upsertEntry,
    this._deleteEntry,
    this._getPlayers,
  ) : super(const MatchEntryState()) {
    on<InitMatchEntries>(_onInit);
    on<ReloadMatchEntries>((_, emit) => _loadEntries(emit));
    on<UpsertMatchEntryRequested>(_onUpsert);
    on<DeleteMatchEntryRequested>(_onDelete);
    on<ClearMatchEntryFeedback>(
      (_, emit) => emit(state.copyWith(clearFeedback: true)),
    );
  }

  Future<void> _onInit(
    InitMatchEntries event,
    Emitter<MatchEntryState> emit,
  ) async {
    emit(state.copyWith(status: MatchEntryStatus.loading, matchId: event.matchId));
    final playersResult = await _getPlayers(const NoParams());
    emit(state.copyWith(allPlayers: playersResult.data ?? const []));
    await _loadEntries(emit);
  }

  Future<void> _loadEntries(Emitter<MatchEntryState> emit) async {
    emit(state.copyWith(status: MatchEntryStatus.loading));
    final result = await _getEntries(state.matchId);
    result.when(
      success: (s) => emit(
        state.copyWith(status: MatchEntryStatus.success, entries: s.data),
      ),
      failure: (f) => emit(
        state.copyWith(
          status: MatchEntryStatus.failure,
          errorMessage: f.error.toString(),
        ),
      ),
    );
  }

  Future<void> _onUpsert(
    UpsertMatchEntryRequested event,
    Emitter<MatchEntryState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));
    final result = await _upsertEntry(event.entry);
    await result.when(
      success: (_) async {
        emit(state.copyWith(isSubmitting: false, actionMessage: 'Entry saved'));
        await _loadEntries(emit);
      },
      failure: (f) async => emit(
        state.copyWith(isSubmitting: false, actionError: f.error.toString()),
      ),
    );
  }

  Future<void> _onDelete(
    DeleteMatchEntryRequested event,
    Emitter<MatchEntryState> emit,
  ) async {
    final result = await _deleteEntry(event.id);
    await result.when(
      success: (_) async {
        emit(state.copyWith(actionMessage: 'Entry deleted'));
        await _loadEntries(emit);
      },
      failure: (f) async =>
          emit(state.copyWith(actionError: f.error.toString())),
    );
  }
}
