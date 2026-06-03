import 'package:equatable/equatable.dart';

class AdCreditTxnModel extends Equatable {
  final String  id;
  final String  establishmentId;
  final double  amountMxn;   // positivo = carga, negativo = débito
  final String  type;        // purchase | impression_debit | refund | manual_admin
  final String? referenceId;
  final String? note;
  final DateTime createdAt;

  const AdCreditTxnModel({
    required this.id,
    required this.establishmentId,
    required this.amountMxn,
    required this.type,
    required this.createdAt,
    this.referenceId,
    this.note,
  });

  bool get isCredit => amountMxn > 0;

  String get typeLabel {
    switch (type) {
      case 'purchase':         return 'Recarga';
      case 'impression_debit': return 'Impresiones';
      case 'refund':           return 'Reembolso';
      case 'manual_admin':     return 'Ajuste manual';
      default:                 return type;
    }
  }

  factory AdCreditTxnModel.fromJson(Map<String, dynamic> json) {
    return AdCreditTxnModel(
      id:              json['id']               as String,
      establishmentId: json['establishment_id'] as String,
      amountMxn:      (json['amount_mxn']       as num).toDouble(),
      type:            json['type']             as String,
      referenceId:     json['reference_id']     as String?,
      note:            json['note']             as String?,
      createdAt:       DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props =>
      [id, establishmentId, amountMxn, type, referenceId, note, createdAt];
}
