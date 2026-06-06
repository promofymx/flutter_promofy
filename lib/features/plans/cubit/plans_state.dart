import 'package:equatable/equatable.dart';
import '../../../data/models/membership_plan_model.dart';
import '../../../data/models/subscription_model.dart';

abstract class PlansState extends Equatable {
  const PlansState();
  @override
  List<Object?> get props => [];
}

class PlansInitial extends PlansState {
  const PlansInitial();
}

class PlansLoading extends PlansState {
  const PlansLoading();
}

/// Estado principal: planes cargados + suscripción actual.
class PlansLoaded extends PlansState {
  final List<MembershipPlanModel> plans;
  final UserSubscriptionData      subscription;
  final List<AddOnPurchaseModel>  addOns;
  /// Add-ons activos como suscripción mensual (filas de add_on_subscriptions).
  final List<Map<String, dynamic>> addonSubscriptions;
  /// true mientras se espera respuesta de una Edge Function de pago.
  final bool                      isProcessing;

  const PlansLoaded({
    required this.plans,
    required this.subscription,
    this.addOns             = const [],
    this.addonSubscriptions = const [],
    this.isProcessing       = false,
  });

  PlansLoaded copyWith({
    List<MembershipPlanModel>?  plans,
    UserSubscriptionData?       subscription,
    List<AddOnPurchaseModel>?   addOns,
    List<Map<String, dynamic>>? addonSubscriptions,
    bool?                       isProcessing,
  }) {
    return PlansLoaded(
      plans:              plans              ?? this.plans,
      subscription:       subscription       ?? this.subscription,
      addOns:             addOns             ?? this.addOns,
      addonSubscriptions: addonSubscriptions ?? this.addonSubscriptions,
      isProcessing:       isProcessing       ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props =>
      [plans, subscription, addOns, addonSubscriptions, isProcessing];
}

/// Se emite cuando la URL de pago está lista → la pantalla abre el WebView.
class PlansPaymentReady extends PlansState {
  final String     checkoutUrl;
  final String     type;        // 'subscription' | 'addon'
  final PlansLoaded loaded;     // estado anterior para restaurar tras el WebView

  const PlansPaymentReady({
    required this.checkoutUrl,
    required this.type,
    required this.loaded,
  });

  @override
  List<Object?> get props => [checkoutUrl, type, loaded];
}

class PlansError extends PlansState {
  final String message;
  const PlansError(this.message);
  @override
  List<Object?> get props => [message];
}
