import '../../domain/entities/season_entity.dart';

class SeasonModel extends SeasonEntity {
  const SeasonModel({
    required super.id,
    required super.startDate,
    super.name,
    super.endDate,
    super.isCurrent,
  });

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    return SeasonModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      startDate:
          DateTime.tryParse(json['start_date']?.toString() ?? '') ??
              DateTime.now(),
      endDate: json['end_date'] == null
          ? null
          : DateTime.tryParse(json['end_date'].toString()),
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }

  /// Map used for inserts/updates. `id` is identity-generated, so it is omitted.
  Map<String, dynamic> toWriteMap() {
    return {
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_current': isCurrent,
    };
  }
}
