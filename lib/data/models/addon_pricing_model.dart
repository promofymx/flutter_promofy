import 'package:equatable/equatable.dart';

/// Precio de un add-on de membresía (establecimiento extra, promoción extra, etc.).
/// Corresponde a la tabla `addon_pricing` en Supabase.
class AddonPricingModel extends Equatable {
  final int    id;
  /// Identificador de tipo: 'extra_establishment' | 'extra_promotion'
  final String type;
  /// Nombre visible en la UI (ej. "Establecimiento adicional")
  final String label;
  /// Descripción corta (ej. "Precio mensual por negocio extra")
  final String description;
  /// Precio mensual por unidad en MXN
  final double priceMxn;

  const AddonPricingModel({
    required this.id,
    required this.type,
    required this.label,
    required this.description,
    required this.priceMxn,
  });

  factory AddonPricingModel.fromJson(Map<String, dynamic> json) {
    return AddonPricingModel(
      id:          json['id']           as int,
      type:        json['type']         as String,
      label:       json['label']        as String,
      description: (json['description'] as String?) ?? '',
      priceMxn:   (json['price_mxn']   as num).toDouble(),
    );
  }

  AddonPricingModel copyWith({double? priceMxn}) => AddonPricingModel(
        id:          id,
        type:        type,
        label:       label,
        description: description,
        priceMxn:    priceMxn ?? this.priceMxn,
      );

  @override
  List<Object?> get props => [id, type, label, description, priceMxn];
}
