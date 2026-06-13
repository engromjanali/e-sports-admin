import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/competition_entity.dart';
import '../../domain/usecases/competition_usecases.dart';

// ----------------------------- Events -----------------------------
sealed class CompetitionEvent extends Equatable {
  const CompetitionEvent();
  @override
  List<Object?> get props => [];
}

class LoadCompetitions extends CompetitionEvent {
  const LoadCompetitions();
}

class CreateCompetitionRequested extends CompetitionEvent {
  final CompetitionEntity competition;
  const CreateCompetitionRequested(this.competition);
  @override
  List<Object?> get props => [competition];
}

class UpdateCompetitionRequested extends CompetitionEvent {
  final CompetitionEntity competition;
  const UpdateCompetitionRequested(this.competition);
  @override
  List<Object?> get props => [competition];
}

class DeleteCompetitionRequested extends CompetitionEvent {
  final int id;
  const DeleteCompetitionRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class ClearCompetitionFeedback extends CompetitionEvent {
  const ClearCompetitionFeedback();
}

// ----------------------------- State -----------------------------
enum CompetitionStatus { initial, loading, success, failure }

class CompetitionState extends Equatable {
  final CompetitionStatus status;
  final List<CompetitionEntity> competitions;
  final String? errorMessage;
  final bool isSubmitting;
  final String? actionMessage;
  final String? actionError;

  const CompetitionState({
    this.status = CompetitionStatus.initial,
    this.competitions = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.actionMessage,
    this.actionError,
  });

  CompetitionState copyWith({
    CompetitionStatus? status,
    List<CompetitionEntity>? competitions,
    String? errorMessage,
    bool? isSubmitting,
    String? actionMessage,
    String? actionError,
    bool clearFeedback = false,
  }) {
    return CompetitionState(
      status: status ?? this.status,
      competitions: competitions ?? this.competitions,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionMessage:
          clearFeedback ? null : (actionMessage ?? this.actionMessage),
      actionError: clearFeedback ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props =>
      [status, competitions, errorMessage, isSubmitting, actionMessage, actionError];
}

// ----------------------------- Bloc -----------------------------
@injectable
class CompetitionBloc extends Bloc<CompetitionEvent, CompetitionState> {
  final GetCompetitionsUseCase _getCompetitions;
  final CreateCompetitionUseCase _createCompetition;
  final UpdateCompetitionUseCase _updateCompetition;
  final DeleteCompetitionUseCase _deleteCompetition;

  CompetitionBloc(
    this._getCompetitions,
    this._createCompetition,
    this._updateCompetition,
    this._deleteCompetition,
  ) : super(const CompetitionState()) {
    on<LoadCompetitions>(_onLoad);
    on<CreateCompetitionRequested>(_onCreate);
    on<UpdateCompetitionRequested>(_onUpdate);
    on<DeleteCompetitionRequested>(_onDelete);
    on<ClearCompetitionFeedback>(
      (_, emit) => emit(state.copyWith(clearFeedback: true)),
    );
  }

  Future<void> _onLoad(
      LoadCompetitions event, Emitter<CompetitionState> emit) async {
    emit(state.copyWith(status: CompetitionStatus.loading));
    final result = await _getCompetitions(const NoParams());
    result.when(
      success: (s) => emit(state.copyWith(
          status: CompetitionStatus.success, competitions: s.data)),
      failure: (f) => emit(state.copyWith(
          status: CompetitionStatus.failure,
          errorMessage: f.error.toString())),
    );
  }

  Future<void> _onCreate(
      CreateCompetitionRequested event, Emitter<CompetitionState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));
    final result = await _createCompetition(event.competition);
    await result.when(
      success: (_) async {
        emit(state.copyWith(
            isSubmitting: false, actionMessage: 'Competition added'));
        add(const LoadCompetitions());
      },
      failure: (f) async => emit(state.copyWith(
          isSubmitting: false, actionError: f.error.toString())),
    );
  }

  Future<void> _onUpdate(
      UpdateCompetitionRequested event, Emitter<CompetitionState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));
    final result = await _updateCompetition(event.competition);
    await result.when(
      success: (_) async {
        emit(state.copyWith(
            isSubmitting: false, actionMessage: 'Competition updated'));
        add(const LoadCompetitions());
      },
      failure: (f) async => emit(state.copyWith(
          isSubmitting: false, actionError: f.error.toString())),
    );
  }

  Future<void> _onDelete(
      DeleteCompetitionRequested event, Emitter<CompetitionState> emit) async {
    final result = await _deleteCompetition(event.id);
    result.when(
      success: (_) {
        emit(state.copyWith(actionMessage: 'Competition deleted'));
        add(const LoadCompetitions());
      },
      failure: (f) =>
          emit(state.copyWith(actionError: f.error.toString())),
    );
  }
}
