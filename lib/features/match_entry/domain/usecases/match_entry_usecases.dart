import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/match_entry_entity.dart';
import '../repositories/match_entry_repository.dart';

@lazySingleton
class GetMatchEntriesUseCase
    implements UseCase<List<MatchEntryEntity>, String> {
  final MatchEntryRepository _repository;
  GetMatchEntriesUseCase(this._repository);

  @override
  ResultFuture<List<MatchEntryEntity>> call(String matchId) =>
      _repository.getEntries(matchId);
}

@lazySingleton
class UpsertMatchEntryUseCase
    implements UseCase<MatchEntryEntity, MatchEntryEntity> {
  final MatchEntryRepository _repository;
  UpsertMatchEntryUseCase(this._repository);

  @override
  ResultFuture<MatchEntryEntity> call(MatchEntryEntity params) =>
      _repository.upsertEntry(params);
}

@lazySingleton
class DeleteMatchEntryUseCase implements UseCase<void, String> {
  final MatchEntryRepository _repository;
  DeleteMatchEntryUseCase(this._repository);

  @override
  ResultVoid call(String params) => _repository.deleteEntry(params);
}
