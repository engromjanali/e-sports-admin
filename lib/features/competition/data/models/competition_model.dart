import '../../domain/entities/competition_entity.dart';

class CompetitionModel extends CompetitionEntity {
  const CompetitionModel({
    required super.id,
    required super.name,
    super.isActive,
  });

  factory CompetitionModel.fromJson(Map<String, dynamic> json) {
    return CompetitionModel(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toWriteMap() {
    return {
      'name': name,
      'is_active': isActive,
    };
  }
}
