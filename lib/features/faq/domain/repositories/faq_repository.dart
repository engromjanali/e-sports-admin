import '../../../../config/util/result.dart';
import '../entities/faq_entity.dart';

abstract class FaqRepository {
  ResultFuture<List<FaqEntity>> getFaqs();
  ResultFuture<FaqEntity> createFaq(FaqEntity faq);
  ResultFuture<FaqEntity> updateFaq(FaqEntity faq);
  ResultVoid deleteFaq(int id);
}
