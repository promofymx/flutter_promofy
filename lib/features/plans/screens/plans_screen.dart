import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/membership_plan_model.dart';
import '../../../data/repositories/plans_repository.dart';
import '../cubit/plans_cubit.dart';
import '../cubit/plans_state.dart';
import 'payment_webview_screen.dart';

/// Pantalla de planes y pagos. Se abre desde el perfil o desde el panel de negocio.
/// Crea su propio PlansCubit para mantenerse aislada.
///
/// [onPaymentSuccess] se ejecuta después de que el pago es aprobado o queda
/// pendiente — úsalo para canjear un código o reclamar un establecimiento.
class PlansScreen extends StatelessWidget {
  final Future<void> Function()? onPaymentSuccess;
  const PlansScreen({super.key, this.onPaymentSuccess});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlansCubit(repository: PlansRepository())..load(),
      child: _PlansBody(onPaymentSuccess: onPaymentSuccess),
    );
  }
}

// ─── Body principal ───────────────────────────────────────────────────────────

class _PlansBody extends StatelessWidget {
  final Future<void> Function()? onPaymentSuccess;
  const _PlansBody({this.onPaymentSuccess});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlansCubit, PlansState>(
      listener: (context, state) async {
        // Cuando hay URL de pago lista → abrir WebView
        if (state is PlansPaymentReady) {
          final cubit = context.read<PlansCubit>();
          final result = await Navigator.of(context).push<PaymentResult>(
            MaterialPageRoute(
              builder: (_) => PaymentWebViewScreen(
                checkoutUrl: state.checkoutUrl,
                title: state.type == 'subscription'
                    ? 'Suscripción Promofy'
                    : 'Comprar add-on',
              ),
            ),
          );

          // Restaurar el estado loaded mientras esperamos el webhook de MP
          cubit.restoreLoaded(state.loaded);

          if (result == PaymentResult.success ||
              result == PaymentResult.pending) {
            // Refrescar la suscripción después de un pequeño delay
            await Future.delayed(const Duration(seconds: 2));
            cubit.refreshSubscription();

            // Callback post-pago (canjear código / reclamar establecimiento)
            if (onPaymentSuccess != null && context.mounted) {
              try { await onPaymentSuccess!(); } catch (_) { /* silencioso */ }
            }

            if (context.mounted) {
              _showPaymentResultDialog(
                context,
                success: result == PaymentResult.success,
              );
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          title: const Text(
            'Planes y pagos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: BlocBuilder<PlansCubit, PlansState>(
          builder: (context, state) {
            if (state is PlansLoading) {
              return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5));
            }
            if (state is PlansError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.grey.shade400, size: 40),
                      const SizedBox(height: 12),
                      Text(state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14)),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () =>
                            context.read<PlansCubit>().load(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final loaded = state is PlansLoaded
                ? state
                : (state is PlansPaymentReady ? state.loaded : null);
            if (loaded == null) return const SizedBox.shrink();

            return RefreshIndicator(
              onRefresh: () => context.read<PlansCubit>().load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  // Badge plan actual
                  _CurrentPlanBadge(subscription: loaded.subscription),
                  const SizedBox(height: 20),

                  // Tarjetas de planes
                  ...loaded.plans
                      .where((p) => p.isActive)
                      .map((plan) => _PlanCard(
                            plan:          plan,
                            isCurrentPlan: loaded.subscription.effectivePlanId == plan.id,
                            isProcessing:  loaded.isProcessing,
                          )),

                  // Add-ons: sólo para suscriptores activos
                  if (loaded.subscription.hasActivePlan) ...[
                    const SizedBox(height: 28),
                    const _AddOnsSection(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPaymentResultDialog(BuildContext context,
      {required bool success}) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.schedule_rounded,
              color: success ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(success ? '¡Pago aprobado!' : 'Pago en proceso'),
          ],
        ),
        content: Text(
          success
              ? 'Tu suscripción fue activada correctamente. '
                  'Ya puedes disfrutar de todos los beneficios de tu plan.'
              : 'Tu pago está siendo procesado. En cuanto se confirme, '
                  'tu plan se actualizará automáticamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

// ─── Badge plan actual ────────────────────────────────────────────────────────

class _CurrentPlanBadge extends StatelessWidget {
  final dynamic subscription; // UserSubscriptionData
  const _CurrentPlanBadge({required this.subscription});

  @override
  Widget build(BuildContext context) {
    // Muestra el nombre del plan sólo cuando existe una suscripción real.
    // Si sólo hay un plan_id por defecto en profiles (sin fila de suscripción),
    // se muestra "Sin plan activo" para no confundir al usuario.
    final planName = subscription.subscription != null
        ? (subscription.plan?.name ?? 'Plan activo')
        : 'Sin plan activo';
    final isActive = subscription.hasActivePlan as bool;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [AppColors.primary, AppColors.primary.withAlpha(200)]
              : [Colors.grey.shade600, Colors.grey.shade500],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:        Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu plan actual',
                  style: TextStyle(
                      fontSize: 11,
                      color:    Colors.white.withAlpha(200),
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  planName,
                  style: const TextStyle(
                      fontSize:   18,
                      color:      Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color:        Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Activo',
                style: TextStyle(
                    fontSize:   11,
                    color:      Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Tarjeta de plan ──────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final MembershipPlanModel plan;
  final bool                isCurrentPlan;
  final bool                isProcessing;

  const _PlanCard({
    required this.plan,
    required this.isCurrentPlan,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    final isFree      = plan.isFree;
    final borderColor = isCurrentPlan
        ? AppColors.primary
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withAlpha(10),
            blurRadius: 8,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del plan
          Container(
            padding:     const EdgeInsets.fromLTRB(18, 16, 18, 14),
            decoration: BoxDecoration(
              color: isCurrentPlan
                  ? AppColors.primary.withAlpha(12)
                  : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize:   16,
                              fontWeight: FontWeight.bold,
                              color: isCurrentPlan
                                  ? AppColors.primary
                                  : AppColors.textDark,
                            ),
                          ),
                          if (isCurrentPlan) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color:        AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Actual',
                                style: TextStyle(
                                    fontSize: 10,
                                    color:    Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: isFree
                                  ? 'Gratis'
                                  : '\$${plan.priceMxn.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize:   22,
                                fontWeight: FontWeight.bold,
                                color: isCurrentPlan
                                    ? AppColors.primary
                                    : AppColors.textDark,
                              ),
                            ),
                            if (!isFree)
                              TextSpan(
                                text: ' MXN/mes',
                                style: TextStyle(
                                    fontSize: 12,
                                    color:    Colors.grey.shade500),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isFree
                      ? Icons.store_outlined
                      : Icons.workspace_premium_rounded,
                  color: isCurrentPlan
                      ? AppColors.primary
                      : Colors.grey.shade400,
                  size: 32,
                ),
              ],
            ),
          ),

          // Features
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: Column(
              children: [
                _FeatureRow(
                  icon:  Icons.store_outlined,
                  label: '${plan.maxEstablishments} '
                      'establecimiento${plan.maxEstablishments != 1 ? "s" : ""}',
                ),
                _FeatureRow(
                  icon:  Icons.local_offer_outlined,
                  label: '${plan.maxPromotions} promociones activas',
                ),
                if (plan.maxPushNotifications > 0)
                  _FeatureRow(
                    icon:  Icons.notifications_outlined,
                    label:
                        '${plan.maxPushNotifications} notificaciones push/mes',
                  ),
                _FeatureRow(
                  icon:  Icons.loyalty_outlined,
                  label: 'Programa de lealtad con QR',
                ),
                _FeatureRow(
                  icon:  Icons.bar_chart_rounded,
                  label: 'Estadísticas de negocio',
                ),
              ],
            ),
          ),

          // Botón CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: _PlanCTA(
              plan:         plan,
              isCurrentPlan: isCurrentPlan,
              isProcessing:  isProcessing,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _FeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class _PlanCTA extends StatelessWidget {
  final MembershipPlanModel plan;
  final bool                isCurrentPlan;
  final bool                isProcessing;
  const _PlanCTA({
    required this.plan,
    required this.isCurrentPlan,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    if (plan.isFree) return const SizedBox.shrink();
    if (isCurrentPlan) {
      return OutlinedButton.icon(
        onPressed: null,
        icon:  const Icon(Icons.check_circle_outline, size: 16),
        label: const Text('Plan activo',
            style: TextStyle(fontSize: 13)),
        style: OutlinedButton.styleFrom(
          minimumSize:    const Size(double.infinity, 40),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: isProcessing
          ? null
          : () => _onSubscribe(context),
      icon: isProcessing
          ? const SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.credit_card_outlined, size: 16),
      label: Text(
        isProcessing ? 'Procesando...' : 'Suscribirme',
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 40),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onSubscribe(BuildContext context) {
    context.read<PlansCubit>().subscribeToPlan(plan.id).catchError((e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    });
  }
}

// ─── Sección de Add-ons ───────────────────────────────────────────────────────

class _AddOnsSection extends StatelessWidget {
  const _AddOnsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color:        AppColors.secondary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_shopping_cart_outlined,
                      size: 13, color: AppColors.secondary),
                  SizedBox(width: 4),
                  Text(
                    'ADD-ONS',
                    style: TextStyle(
                      fontSize:    10,
                      fontWeight:  FontWeight.w700,
                      color:       AppColors.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Amplía tu plan con extras de un solo pago.',
          style: TextStyle(
              fontSize: 12,
              color:    Colors.grey.shade500,
              height:   1.3),
        ),
        const SizedBox(height: 12),
        _AddOnTile(
          icon:        Icons.store_outlined,
          title:       '1 establecimiento adicional',
          description: 'Agrega un local extra a tu cuenta de forma permanente.',
          price:       '\$199 MXN',
          addOnType:   'extra_establishment',
        ),
        _AddOnTile(
          icon:        Icons.local_offer_outlined,
          title:       'Pack 10 promociones',
          description: 'Activa 10 promociones adicionales en cualquier local.',
          price:       '\$49 MXN',
          addOnType:   'extra_promotions',
        ),
      ],
    );
  }
}

class _AddOnTile extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   description;
  final String   price;
  final String   addOnType;

  const _AddOnTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.price,
    required this.addOnType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlansCubit, PlansState>(
      builder: (context, state) {
        final isProcessing = state is PlansLoaded && state.isProcessing;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withAlpha(8),
                blurRadius: 6,
                offset:     const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:        AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize:   13,
                            fontWeight: FontWeight.w600,
                            color:      AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text(description,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500,
                            height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price,
                      style: const TextStyle(
                          fontSize:   14,
                          fontWeight: FontWeight.bold,
                          color:      AppColors.textDark)),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () => _onBuy(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize:   Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle:     const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Comprar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _onBuy(BuildContext context) {
    context.read<PlansCubit>().purchaseAddOn(addOnType).catchError((e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    });
  }
}
