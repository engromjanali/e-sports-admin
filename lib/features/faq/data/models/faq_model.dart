import '../../domain/entities/faq_entity.dart';

class FaqModel extends FaqEntity {
  const FaqModel({
    required super.id,
    required super.question,
    required super.answer,
    super.category,
    super.displayOrder,
    super.isActive,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: (json['id'] as num).toInt(),
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toWriteMap() {
    return {
      'question': question,
      'answer': answer,
      'category': category,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }
}
