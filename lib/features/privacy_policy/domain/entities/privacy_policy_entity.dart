import 'package:equatable/equatable.dart';

class PrivacyPolicyEntity extends Equatable {
  final int id;
  final String content;
  final DateTime? updatedAt;

  const PrivacyPolicyEntity({
    required this.id,
    required this.content,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, content, updatedAt];
}
