import '../../../../config/util/result.dart';
import '../entities/hall_of_fame_entity.dart';

abstract class HallOfFameRepository {
  ResultFuture<List<HallOfFameEntity>> getEntries();
  ResultFuture<HallOfFameEntity> createEntry(HallOfFameEntity entry);
  ResultFuture<HallOfFameEntity> updateEntry(HallOfFameEntity entry);
  ResultVoid deleteEntry(String id);
}
