import '../../../../config/util/result.dart';
import '../entities/match_entry_entity.dart';

abstract class MatchEntryRepository {
  ResultFuture<List<MatchEntryEntity>> getEntries(int seasonId);
  ResultFuture<MatchEntryEntity> upsertEntry(MatchEntryEntity entry);
  ResultVoid deleteEntry(String id);
}
