import 'membership_plan_model.dart';

// ─── Suscripción activa del usuario ──────────────────────────────────────────

class UserSubscriptionModel {
  final String    id;
  final int       planId;
  final String?   mpPreapprovalId;
  final String    status;          // pending | authorized | paused | cancelled
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime  createdAt;

  const UserSubscriptionModel({
    required this.id,
    required this.planId,
    required this.status,
    required this.createdAt,
    this.mpPreapprovalId,
    this.currentPeriodStart,
    this.currentPeriodEnd,
  });

  bool get isActive    => status == 'authorized';
  bool get isPending   => status == 'pending';
  bool get isCancelled => status == 'cancelled';

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      id:                 json['id']              as String,
      planId:            (json['plan_id']          as num).toInt(),
      mpPreapprovalId:    json['mp_preapproval_id'] as String?,
      status:             json['status']           as String? ?? 'pending',
      currentPeriodStart: json['current_period_start'] != null
          ? DateTime.parse(json['current_period_start'] as String).toLocal()
          : null,
      currentPeriodEnd: json['current_period_end'] != null
          ? DateTime.parse(json['current_period_end'] as String).toLocal()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}

// ─── Contenedor: suscripción + plan ──────────────────────────────────────────

class UserSubscriptionData {
  final UserSubscriptionModel? subscription;
  final MembershipPlanModel?   plan;

  const UserSubscriptionData({this.subscription, this.plan});

  bool get hasActivePlan =>
      subscription != null && subscription!.isActive;

  /// Plan ID efectivo — sólo cuando la suscripción está ACTIVA (authorized).
  /// Las suscripciones pending/cancelled no marcan ningún plan como "Actual".
  int? get effectivePlanId => hasActivePlan ? plan?.id : null;

  factory UserSubscriptionData.fromJson(Map<String, dynamic> json) {
    final subJson  = json['subscription'] as Map<String, dynamic>?;
    final planJson = json['plan']         as Map<String, dynamic>?;

    return UserSubscriptionData(
      subscription: subJson  != null ? UserSubscriptionModel.fromJson(subJson)  : null,
      plan:         planJson != null ? MembershipPlanModel.fromJson(planJson)    : null,
    );
  }
}

// ─── Add-on purchase ─────────────────────────────────────────────────────────

class AddOnPurchaseModel {
  final String    id;
  final String    addOnType;
  final String?   mpPaymentId;
  final int       quantity;
  final double?   amountPaid;
  final String    status;     // pending | approved | rejected
  final DateTime  createdAt;

  const AddOnPurchaseModel({
    required this.id,
    required this.addOnType,
    required this.quantity,
    required this.status,
    required this.createdAt,
    this.mpPaymentId,
    this.amountPaid,
  });

  bool get isApproved => status == 'approved';

  factory AddOnPurchaseModel.fromJson(Map<String, dynamic> json) {
    return AddOnPurchaseModel(
      id:          json['id']           as String,
      addOnType:   json['add_on_type']  as String,
      mpPaymentId: json['mp_payment_id'] as String?,
      quantity:   (json['quantity']      as num).toInt(),
      amountPaid: (json['amount_paid']   as num?)?.toDouble(),
      status:      json['status']       as String? ?? 'pending',
      createdAt:   DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}
