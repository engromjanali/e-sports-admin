import '../../domain/entities/privacy_policy_entity.dart';

class PrivacyPolicyModel extends PrivacyPolicyEntity {
  const PrivacyPolicyModel({
    required super.id,
    required super.content,
    super.updatedAt,
  });

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      content: json['content']?.toString() ?? '',
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toWriteMap() {
    return {
      'content': content,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
