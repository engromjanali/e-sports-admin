import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/faq_entity.dart';
import '../repositories/faq_repository.dart';

@lazySingleton
class GetFaqsUseCase implements UseCase<List<FaqEntity>, NoParams> {
  final FaqRepository _repository;
  GetFaqsUseCase(this._repository);

  @override
  ResultFuture<List<FaqEntity>> call(NoParams params) => _repository.getFaqs();
}

@lazySingleton
class CreateFaqUseCase implements UseCase<FaqEntity, FaqEntity> {
  final FaqRepository _repository;
  CreateFaqUseCase(this._repository);

  @override
  ResultFuture<FaqEntity> call(FaqEntity params) => _repository.createFaq(params);
}

@lazySingleton
class UpdateFaqUseCase implements UseCase<FaqEntity, FaqEntity> {
  final FaqRepository _repository;
  UpdateFaqUseCase(this._repository);

  @override
  ResultFuture<FaqEntity> call(FaqEntity params) => _repository.updateFaq(params);
}

@lazySingleton
class DeleteFaqUseCase implements UseCase<void, int> {
  final FaqRepository _repository;
  DeleteFaqUseCase(this._repository);

  @override
  ResultVoid call(int params) => _repository.deleteFaq(params);
}
