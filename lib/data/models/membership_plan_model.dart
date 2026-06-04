import 'package:equatable/equatable.dart';

class MembershipPlanModel extends Equatable {
  final int     id;
  final String  name;
  final double  priceMxn;
  /// Precio antes del descuento de lanzamiento. Null si no hay promo activa.
  final double? originalPriceMxn;
  final int     maxEstablishments;
  final int     maxPromotions;
  final int     maxPushNotifications;
  final bool    isActive;
  final int     sortOrder;
  /// ID del preapproval plan en MercadoPago (null → usa auto_recurring directo).
  final String? mpPreapprovalPlanId;

  const MembershipPlanModel({
    required this.id,
    required this.name,
    required this.priceMxn,
    this.originalPriceMxn,
    required this.maxEstablishments,
    required this.maxPromotions,
    this.maxPushNotifications = 0,
    this.isActive             = true,
    this.sortOrder            = 0,
    this.mpPreapprovalPlanId,
  });

  bool get isFree => priceMxn == 0;

  factory MembershipPlanModel.fromJson(Map<String, dynamic> json) {
    return MembershipPlanModel(
      id:                   json['id']                     as int,
      name:                 json['name']                   as String,
      priceMxn:            (json['price_mxn']              as num).toDouble(),
      originalPriceMxn:    (json['original_price_mxn']     as num?)?.toDouble(),
      maxEstablishments:    json['max_establishments']      as int,
      maxPromotions:        json['max_promotions']          as int,
      maxPushNotifications:(json['max_push_notifications']  as int?) ?? 0,
      isActive:            (json['is_active']               as bool?) ?? true,
      sortOrder:           (json['sort_order']              as int?)  ?? 0,
      mpPreapprovalPlanId:  json['mp_preapproval_plan_id']  as String?,
    );
  }

  bool get hasLaunchPromo =>
      originalPriceMxn != null && originalPriceMxn! > priceMxn;

  MembershipPlanModel copyWith({
    int?    id,
    String? name,
    double? priceMxn,
    double? originalPriceMxn,
    int?    maxEstablishments,
    int?    maxPromotions,
    int?    maxPushNotifications,
    bool?   isActive,
    int?    sortOrder,
    String? mpPreapprovalPlanId,
  }) {
    return MembershipPlanModel(
      id:                   id                   ?? this.id,
      name:                 name                 ?? this.name,
      priceMxn:             priceMxn             ?? this.priceMxn,
      originalPriceMxn:     originalPriceMxn     ?? this.originalPriceMxn,
      maxEstablishments:    maxEstablishments    ?? this.maxEstablishments,
      maxPromotions:        maxPromotions        ?? this.maxPromotions,
      maxPushNotifications: maxPushNotifications ?? this.maxPushNotifications,
      isActive:             isActive             ?? this.isActive,
      sortOrder:            sortOrder            ?? this.sortOrder,
      mpPreapprovalPlanId:  mpPreapprovalPlanId  ?? this.mpPreapprovalPlanId,
    );
  }

  @override
  List<Object?> get props => [
    id, name, priceMxn, originalPriceMxn, maxEstablishments, maxPromotions,
    maxPushNotifications, isActive, sortOrder, mpPreapprovalPlanId,
  ];
}
