import 'package:equatable/equatable.dart';

class FaqEntity extends Equatable {
  final int id;
  final String question;
  final String answer;
  final String category;
  final int displayOrder;
  final bool isActive;

  const FaqEntity({
    required this.id,
    required this.question,
    required this.answer,
    this.category = 'General',
    this.displayOrder = 0,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, question, answer, category, displayOrder, isActive];
}
