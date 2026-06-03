import 'package:equatable/equatable.dart';

class AdCreditModel extends Equatable {
  final String id;
  final String establishmentId;
  final double balanceMxn;
  final DateTime updatedAt;

  const AdCreditModel({
    required this.id,
    required this.establishmentId,
    required this.balanceMxn,
    required this.updatedAt,
  });

  factory AdCreditModel.fromJson(Map<String, dynamic> json) {
    return AdCreditModel(
      id:              json['id']               as String,
      establishmentId: json['establishment_id'] as String,
      balanceMxn:     (json['balance_mxn']      as num).toDouble(),
      updatedAt:       DateTime.parse(json['updated_at'] as String),
    );
  }

  AdCreditModel copyWith({double? balanceMxn, DateTime? updatedAt}) {
    return AdCreditModel(
      id:              id,
      establishmentId: establishmentId,
      balanceMxn:      balanceMxn  ?? this.balanceMxn,
      updatedAt:       updatedAt   ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, establishmentId, balanceMxn, updatedAt];
}
