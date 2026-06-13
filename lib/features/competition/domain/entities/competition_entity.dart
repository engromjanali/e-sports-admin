import 'package:equatable/equatable.dart';

class CompetitionEntity extends Equatable {
  final int id;
  final String name;
  final bool isActive;

  const CompetitionEntity({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, isActive];
}
