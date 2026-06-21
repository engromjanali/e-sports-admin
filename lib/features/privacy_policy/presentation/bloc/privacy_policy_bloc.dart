import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/privacy_policy_entity.dart';
import '../../domain/usecases/privacy_policy_usecases.dart';

// ----------------------------- Events -----------------------------
sealed class PrivacyPolicyEvent extends Equatable {
  const PrivacyPolicyEvent();
  @override
  List<Object?> get props => [];
}

class LoadPrivacyPolicy extends PrivacyPolicyEvent {
  const LoadPrivacyPolicy();
}

class SavePrivacyPolicyRequested extends PrivacyPolicyEvent {
  final String content;
  const SavePrivacyPolicyRequested(this.content);
  @override
  List<Object?> get props => [content];
}

class ClearPrivacyPolicyFeedback extends PrivacyPolicyEvent {
  const ClearPrivacyPolicyFeedback();
}

// ----------------------------- State -----------------------------
enum PrivacyPolicyStatus { initial, loading, success, failure }

class PrivacyPolicyState extends Equatable {
  final PrivacyPolicyStatus status;
  final PrivacyPolicyEntity? policy;
  final String? errorMessage;
  final bool isSubmitting;
  final String? actionMessage;
  final String? actionError;

  const PrivacyPolicyState({
    this.status = PrivacyPolicyStatus.initial,
    this.policy,
    this.errorMessage,
    this.isSubmitting = false,
    this.actionMessage,
    this.actionError,
  });

  PrivacyPolicyState copyWith({
    PrivacyPolicyStatus? status,
    PrivacyPolicyEntity? policy,
    String? errorMessage,
    bool? isSubmitting,
    String? actionMessage,
    String? actionError,
    bool clearFeedback = false,
  }) {
    return PrivacyPolicyState(
      status: status ?? this.status,
      policy: policy ?? this.policy,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionMessage: clearFeedback ? null : (actionMessage ?? this.actionMessage),
      actionError: clearFeedback ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props =>
      [status, policy, errorMessage, isSubmitting, actionMessage, actionError];
}

// ----------------------------- Bloc -----------------------------
@injectable
class PrivacyPolicyBloc extends Bloc<PrivacyPolicyEvent, PrivacyPolicyState> {
  final GetPrivacyPolicyUseCase _getPrivacyPolicy;
  final SavePrivacyPolicyUseCase _savePrivacyPolicy;

  PrivacyPolicyBloc(this._getPrivacyPolicy, this._savePrivacyPolicy)
      : super(const PrivacyPolicyState()) {
    on<LoadPrivacyPolicy>(_onLoad);
    on<SavePrivacyPolicyRequested>(_onSave);
    on<ClearPrivacyPolicyFeedback>(
      (_, emit) => emit(state.copyWith(clearFeedback: true)),
    );
  }

  Future<void> _onLoad(
    LoadPrivacyPolicy event,
    Emitter<PrivacyPolicyState> emit,
  ) async {
    emit(state.copyWith(status: PrivacyPolicyStatus.loading));
    final result = await _getPrivacyPolicy(const NoParams());
    result.when(
      success: (s) => emit(
        state.copyWith(status: PrivacyPolicyStatus.success, policy: s.data),
      ),
      failure: (f) => emit(
        state.copyWith(
          status: PrivacyPolicyStatus.failure,
          errorMessage: f.error.toString(),
        ),
      ),
    );
  }

  Future<void> _onSave(
    SavePrivacyPolicyRequested event,
    Emitter<PrivacyPolicyState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearFeedback: true));
    final entity = PrivacyPolicyEntity(
      id: state.policy?.id ?? 0,
      content: event.content,
    );
    final result = await _savePrivacyPolicy(entity);
    await result.when(
      success: (s) async {
        emit(state.copyWith(
          isSubmitting: false,
          status: PrivacyPolicyStatus.success,
          policy: s.data,
          actionMessage: 'Privacy policy saved',
        ));
      },
      failure: (f) async => emit(
        state.copyWith(isSubmitting: false, actionError: f.error.toString()),
      ),
    );
  }
}
