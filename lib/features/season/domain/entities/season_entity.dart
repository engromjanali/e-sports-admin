import 'package:equatable/equatable.dart';

/// A competitive season. Maps to the `season` table.
class SeasonEntity extends Equatable {
  final int id;
  final String? name;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;

  const SeasonEntity({
    required this.id,
    required this.startDate,
    this.name,
    this.endDate,
    this.isCurrent = false,
  });

  String get displayName =>
      (name == null || name!.isEmpty) ? 'Season $id' : name!;

  @override
  List<Object?> get props => [id, name, startDate, endDate, isCurrent];
}
