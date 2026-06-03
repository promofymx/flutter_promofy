import 'package:equatable/equatable.dart';

class AdPricingModel extends Equatable {
  final int    id;
  final String format;       // splash | featured_list | banner | push | flash
  final String label;        // nombre amigable para mostrar en UI
  final String billingType;  // cpm | per_send | flat_rate
  final double priceMxn;     // precio base por unidad efectiva
  final double minBudgetMxn; // presupuesto mínimo de campaña
  final DateTime updatedAt;

  const AdPricingModel({
    required this.id,
    required this.format,
    required this.label,
    required this.billingType,
    required this.priceMxn,
    required this.minBudgetMxn,
    required this.updatedAt,
  });

  factory AdPricingModel.fromJson(Map<String, dynamic> json) {
    return AdPricingModel(
      id:           json['id']             as int,
      format:       json['format']         as String,
      label:        json['label']          as String,
      billingType:  json['billing_type']   as String,
      priceMxn:    (json['price_mxn']      as num).toDouble(),
      minBudgetMxn:(json['min_budget_mxn'] as num).toDouble(),
      updatedAt:    DateTime.parse(json['updated_at'] as String),
    );
  }

  AdPricingModel copyWith({
    double? priceMxn,
    double? minBudgetMxn,
    DateTime? updatedAt,
  }) {
    return AdPricingModel(
      id:           id,
      format:       format,
      label:        label,
      billingType:  billingType,
      priceMxn:     priceMxn     ?? this.priceMxn,
      minBudgetMxn: minBudgetMxn ?? this.minBudgetMxn,
      updatedAt:    updatedAt    ?? this.updatedAt,
    );
  }

  /// Unidad de cobro calculada según usuarios activos de la plataforma.
  /// CPM: max(10, floor(totalUsers × 5%))
  /// Per-send / flat-rate: siempre 1.
  int effectiveBillingUnit(int totalUsers) {
    if (billingType != 'cpm') return 1;
    return (totalUsers * 0.05).floor().clamp(10, 1000000);
  }

  /// Etiqueta legible del tipo de cobro.
  String billingTypeLabel(int totalUsers) {
    switch (billingType) {
      case 'cpm':
        final unit = effectiveBillingUnit(totalUsers);
        final display = unit >= 1000
            ? '${(unit / 1000).toStringAsFixed(unit % 1000 == 0 ? 0 : 1)}k'
            : unit.toString();
        return format == 'push'
            ? 'Por $display destinatarios'
            : 'Por $display impresiones';
      case 'per_send':  return 'Por envío';
      case 'flat_rate': return 'Tarifa fija por activación';
      default:          return billingType;
    }
  }

  @override
  List<Object?> get props =>
      [id, format, label, billingType, priceMxn, minBudgetMxn, updatedAt];
}
