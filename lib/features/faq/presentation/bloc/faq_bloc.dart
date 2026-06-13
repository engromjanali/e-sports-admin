import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/faq_entity.dart';
import '../../domain/usecases/faq_usecases.dart';

// ----------------------------- Events -----------------------------
sealed class FaqEvent extends Equatable {
  const FaqEvent();
  @override
  List<Object?> get props => [];
}

class LoadFaqs extends FaqEvent {
  const LoadFaqs();
}

class CreateFaqRequested extends FaqEvent {
  final FaqEntity faq;
  const CreateFaqRequested(this.faq);
  @override
  List<Object?> get props => [faq];
}

class UpdateFaqRequested extends FaqEvent {
  final FaqEntity faq;
  const UpdateFaqRequested(this.faq);
  @override
  List<Object?> get props => [faq];
}

class DeleteFaqRequested extends FaqEvent {
  final int id;
  const DeleteFaqRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class ClearFaqFeedback extends FaqEvent {
  const ClearFaqFeedback();
}

// ----------------------------- State -----------------------------
enum FaqStatus { initial, loading, success, failure }

class FaqState extends Equatable {
  final FaqStatus status;
  final List<FaqEntity> faqs;
  final String? errorMessage;
  final bool isSubmitting;
  final String? actionMessage;
  final String? actionError;

  const FaqState({
    this.status = FaqStatus.initial,
    this.faqs = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.actionMessage,
    this.actionError,
  });

  FaqState copyWith({
    FaqStatus? status,
    List<FaqEntity>? faqs,
    String? errorMessage,
    bool? isSubmitting,
    String? actionMessage,
    String? actionError,
    bool clearFeedback = false,
  }) {
    return FaqState(
      status: status ?? this.status,
      faqs: faqs ?? this.faqs,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionMessage: clearFeedback ? null : (actionMessage ?? this.actionMessage),
      actionError: clearFeedback ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props =>
      [status, faqs, errorMessage, isSubmitting, actionMessage, actionError];
}

// ----------------------------- Bloc -----------------------------
@injectable
class FaqBloc extends Bloc<FaqEvent, FaqState> {
  final GetFaqsUseCase _getFaqs;
  final CreateFaqUseCase _createFaq;
  final UpdateFaqUseCase _updateFaq;
  final DeleteFaqUseCase _deleteFaq;

  FaqBloc(this._getFaqs, this._createFaq, this._updateFaq, this._deleteFaq)
      : super(const FaqState()) {
    on<LoadFaqs>(_onLoad);
    on<CreateFaqRequested>(_onCreate);
    on<UpdateFaqRequested>(_onUpdate);
    on<DeleteFaqRequested>(_onDelete);
    on<ClearFaqFeedback>(
      (_, emit) => emit(state.copyWith(clearFeedback: true)),
    );
  }

  Future<void> _onLoad(LoadFaqs event, Emitter<FaqState> emit) async {
    emit(state.copyWith(status: FaqStatus.loading));
    final result = await _getFaqs(const NoParams());
    result.when(
      success: (s) =>
          emit(state.copyWith(status: FaqStatus.success, faqs: s.data)),
      failure: (f) => emit(
        state.copyWith(
          status: FaqStatus.failure,
          errorMessage: f.error.toString(),
        ),
      ),
    );
  }

  Future<void> _onCreate(
    CreateFaqRequested event,
    Emitter<FaqState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));
    final result = await _createFaq(event.faq);
    await result.when(
      success: (_) async {
        emit(state.copyWith(isSubmitting: false, actionMessage: 'FAQ added'));
        add(const LoadFaqs());
      },
      failure: (f) async => emit(
        state.copyWith(isSubmitting: false, actionError: f.error.toString()),
      ),
    );
  }

  Future<void> _onUpdate(
    UpdateFaqRequested event,
    Emitter<FaqState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));
    final result = await _updateFaq(event.faq);
    await result.when(
      success: (_) async {
        emit(state.copyWith(isSubmitting: false, actionMessage: 'FAQ updated'));
        add(const LoadFaqs());
      },
      failure: (f) async => emit(
        state.copyWith(isSubmitting: false, actionError: f.error.toString()),
      ),
    );
  }

  Future<void> _onDelete(
    DeleteFaqRequested event,
    Emitter<FaqState> emit,
  ) async {
    final result = await _deleteFaq(event.id);
    result.when(
      success: (_) {
        emit(state.copyWith(actionMessage: 'FAQ deleted'));
        add(const LoadFaqs());
      },
      failure: (f) => emit(state.copyWith(actionError: f.error.toString())),
    );
  }
}
