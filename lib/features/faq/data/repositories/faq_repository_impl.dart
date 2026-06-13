import 'package:injectable/injectable.dart';

import '../../../../config/util/result.dart';
import '../../../../core/network/supabase_guard.dart';
import '../../domain/entities/faq_entity.dart';
import '../../domain/repositories/faq_repository.dart';
import '../datasources/faq_data_source.dart';
import '../models/faq_model.dart';

@LazySingleton(as: FaqRepository)
class FaqRepositoryImpl implements FaqRepository {
  final FaqDataSource _dataSource;

  FaqRepositoryImpl(this._dataSource);

  FaqModel _toModel(FaqEntity e) => FaqModel(
        id: e.id,
        question: e.question,
        answer: e.answer,
        category: e.category,
        displayOrder: e.displayOrder,
        isActive: e.isActive,
      );

  @override
  ResultFuture<List<FaqEntity>> getFaqs() =>
      guardSupabase(() => _dataSource.getFaqs());

  @override
  ResultFuture<FaqEntity> createFaq(FaqEntity faq) =>
      guardSupabase(() => _dataSource.createFaq(_toModel(faq)));

  @override
  ResultFuture<FaqEntity> updateFaq(FaqEntity faq) =>
      guardSupabase(() => _dataSource.updateFaq(faq.id, _toModel(faq)));

  @override
  ResultVoid deleteFaq(int id) =>
      guardSupabaseVoid(() => _dataSource.deleteFaq(id));
}
