import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promofy/l10n/app_localizations.dart';
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
                    ? AppLocalizations.of(context).plansWebviewSubscriptionTitle
                    : AppLocalizations.of(context).plansWebviewAddonTitle,
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
          title: Text(
            AppLocalizations.of(context).plansAppBarTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
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
                        child: Text(AppLocalizations.of(context).plansRetry),
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

            // ¿algún plan tiene promo activa?
            final hasPromo = loaded.plans.any((p) => p.hasLaunchPromo);

            return RefreshIndicator(
              onRefresh: () => context.read<PlansCubit>().load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  // Banner promo de lanzamiento
                  if (hasPromo) ...[
                    _LaunchPromoBanner(),
                    const SizedBox(height: 16),
                  ],

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
                    if (loaded.addonSubscriptions.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _ActiveAddonsSection(items: loaded.addonSubscriptions),
                    ],
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
            Text(success
                ? AppLocalizations.of(context).plansPaymentApprovedTitle
                : AppLocalizations.of(context).plansPaymentPendingTitle),
          ],
        ),
        content: Text(
          success
              ? AppLocalizations.of(context).plansPaymentApprovedBody
              : AppLocalizations.of(context).plansPaymentPendingBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).plansGotIt),
          ),
        ],
      ),
    );
  }
}

// ─── Banner promo de lanzamiento ─────────────────────────────────────────────

class _LaunchPromoBanner extends StatelessWidget {
  const _LaunchPromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFFF7043)],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:      const Color(0xFFE53935).withAlpha(60),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:        Colors.white.withAlpha(35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🚀', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).plansLaunchPromoTitle,
                  style: const TextStyle(
                    fontSize:   14,
                    fontWeight: FontWeight.bold,
                    color:      Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppLocalizations.of(context).plansLaunchPromoSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color:    Colors.white.withAlpha(220),
                    height:   1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).plansLaunchPromoValidUntil,
                  style: TextStyle(
                    fontSize:   11,
                    color:      Colors.white.withAlpha(180),
                    fontStyle:  FontStyle.italic,
                  ),
                ),
              ],
            ),
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
    final planName = subscription.hasActivePlan
        ? (subscription.plan?.name ??
            AppLocalizations.of(context).plansActivePlanFallback)
        : AppLocalizations.of(context).plansNoActivePlan;
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
                  AppLocalizations.of(context).plansCurrentPlanLabel,
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
              child: Text(
                AppLocalizations.of(context).plansActiveBadge,
                style: const TextStyle(
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
                              child: Text(
                                AppLocalizations.of(context).plansCurrentBadge,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color:    Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (plan.hasLaunchPromo) ...[
                        // Precio tachado (original)
                        Text(
                          AppLocalizations.of(context).plansPricePerMonth(
                              plan.originalPriceMxn!.toStringAsFixed(0)),
                          style: TextStyle(
                            fontSize:      13,
                            color:         Colors.grey.shade400,
                            decoration:    TextDecoration.lineThrough,
                            decorationColor: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: isFree
                                  ? AppLocalizations.of(context).plansFree
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
                                text: AppLocalizations.of(context)
                                    .plansMxnPerMonthSuffix,
                                style: TextStyle(
                                    fontSize: 12,
                                    color:    Colors.grey.shade500),
                              ),
                          ],
                        ),
                      ),
                      // Badge crédito de publicidad
                      if (plan.hasLaunchPromo) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:        Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🎁', style: TextStyle(fontSize: 11)),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context).plansAdCredit(
                                    plan.originalPriceMxn!.toStringAsFixed(0)),
                                style: TextStyle(
                                  fontSize:   11,
                                  fontWeight: FontWeight.w600,
                                  color:      Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                  label: AppLocalizations.of(context)
                      .plansFeatureEstablishments(plan.maxEstablishments),
                ),
                _FeatureRow(
                  icon:  Icons.local_offer_outlined,
                  label: AppLocalizations.of(context)
                      .plansFeaturePromotions(plan.maxPromotions),
                ),
                _FeatureRow(
                  icon:  Icons.flash_on_outlined,
                  label: plan.maxEstablishments == 1
                      ? AppLocalizations.of(context).plansFeatureFlashSingle
                      : AppLocalizations.of(context).plansFeatureFlashMulti,
                ),
                _FeatureRow(
                  icon:  Icons.cake_outlined,
                  label: plan.maxEstablishments == 1
                      ? AppLocalizations.of(context).plansFeatureBirthdaySingle
                      : AppLocalizations.of(context).plansFeatureBirthdayMulti,
                ),
                _FeatureRow(
                  icon:  Icons.loyalty_outlined,
                  label: plan.maxEstablishments == 1
                      ? AppLocalizations.of(context).plansFeatureLoyaltySingle
                      : AppLocalizations.of(context).plansFeatureLoyaltyMulti,
                ),
                _FeatureRow(
                  icon:  Icons.bar_chart_rounded,
                  label: AppLocalizations.of(context).plansFeatureStats,
                ),
                if (plan.maxPushNotifications > 0)
                  _FeatureRow(
                    icon:  Icons.notifications_outlined,
                    label: AppLocalizations.of(context)
                        .plansFeaturePush(plan.maxPushNotifications),
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
        label: Text(AppLocalizations.of(context).plansActivePlanButton,
            style: const TextStyle(fontSize: 13)),
        style: OutlinedButton.styleFrom(
          minimumSize:    const Size(double.infinity, 40),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    // En iOS NO se muestra la compra de planes (regla 3.1.1 de Apple). El dueño
    // contrata/mejora su plan desde la web; aquí solo ve la información.
    if (Platform.isIOS) return const SizedBox.shrink();

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
        isProcessing
            ? AppLocalizations.of(context).plansProcessing
            : AppLocalizations.of(context).plansSubscribe,
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
    // El descuento (si lo hay) se aplica automáticamente en el servidor según
    // el correo del cliente (precio especial asignado desde el superadmin).
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
    // En iOS no se ofrecen add-ons de pago (regla 3.1.1 de Apple).
    if (Platform.isIOS) return const SizedBox.shrink();
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_shopping_cart_outlined,
                      size: 13, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context).plansAddonsLabel,
                    style: const TextStyle(
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
          AppLocalizations.of(context).plansAddonsDescription,
          style: TextStyle(
              fontSize: 12,
              color:    Colors.grey.shade500,
              height:   1.3),
        ),
        const SizedBox(height: 12),
        _AddOnTile(
          icon:        Icons.store_outlined,
          title:       AppLocalizations.of(context).plansAddonEstablishmentTitle,
          description: AppLocalizations.of(context).plansAddonEstablishmentDesc,
          price:       _addonPrice(
            context,
            'extra_establishment',
            AppLocalizations.of(context).plansAddonEstablishmentPrice,
          ),
          addOnType:   'extra_establishment',
        ),
        _AddOnTile(
          icon:        Icons.local_offer_outlined,
          title:       AppLocalizations.of(context).plansAddonPromotionTitle,
          description: AppLocalizations.of(context).plansAddonPromotionDesc,
          price:       _addonPrice(
            context,
            'extra_promotion',
            AppLocalizations.of(context).plansAddonPromotionPrice,
          ),
          addOnType:   'extra_promotion',
        ),
      ],
    );
  }

  /// Precio dinámico del add-on desde la tabla addon_pricing (configurable por
  /// el admin). Si no está disponible, usa el texto por defecto de localización.
  String _addonPrice(BuildContext context, String type, String fallback) {
    final state = context.watch<PlansCubit>().state;
    if (state is PlansLoaded) {
      final price = state.priceForAddon(type);
      if (price != null) return '\$${price.toStringAsFixed(0)} MXN/mes';
    }
    return fallback;
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
                      child: Text(AppLocalizations.of(context).plansBuy),
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

// ─── Mis complementos activos (cancelar suscripciones de add-on) ──────────────

class _ActiveAddonsSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _ActiveAddonsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).plansActiveAddonsTitle,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context).plansActiveAddonsSubtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 12),
        ...items.map((a) => _ActiveAddonRow(addon: a)),
      ],
    );
  }
}

class _ActiveAddonRow extends StatelessWidget {
  final Map<String, dynamic> addon;
  const _ActiveAddonRow({required this.addon});

  String get _type => addon['add_on_type'] as String? ?? '';
  String _labelOf(BuildContext context) => _type == 'extra_promotion'
      ? AppLocalizations.of(context).plansAddonPromotionLabel
      : (_type == 'extra_establishment'
          ? AppLocalizations.of(context).plansAddonEstablishmentLabel
          : _type);

  @override
  Widget build(BuildContext context) {
    final price = (addon['price_mxn'] as num?)?.toStringAsFixed(0) ?? '';
    return Container(
      margin:  const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_labelOf(context),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                Text(AppLocalizations.of(context).plansPricePerMonth(price),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _onCancel(context),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade600),
            child: Text(AppLocalizations.of(context).plansCancel),
          ),
        ],
      ),
    );
  }

  Future<void> _onCancel(BuildContext context) async {
    final cubit = context.read<PlansCubit>();
    final state = cubit.state;
    if (state is! PlansLoaded) return;
    final id = addon['id'] as String;

    List<String> toDeactivate = [];

    // Si es promo y quedarías sobre el límite → elegir cuáles desactivar.
    if (_type == 'extra_promotion') {
      MembershipPlanModel? plan;
      for (final p in state.plans) {
        if (p.id == state.subscription.effectivePlanId) { plan = p; break; }
      }
      final planMax  = plan?.maxPromotions ?? 2;
      final extra    = state.addonSubscriptions
          .where((a) => a['add_on_type'] == 'extra_promotion').length;
      final newMax   = planMax + (extra - 1);
      final promos   = await cubit.activePromotions();
      final excess   = promos.length - newMax;
      if (excess > 0) {
        if (!context.mounted) return;
        final chosen = await _chooseToDeactivate(context, promos, excess);
        if (chosen == null) return; // cerró sin confirmar
        toDeactivate = chosen;
      }
    }

    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).plansCancelAddonTitle),
        content: Text(toDeactivate.isEmpty
            ? AppLocalizations.of(context)
                .plansCancelAddonConfirm(_labelOf(context))
            : AppLocalizations.of(context).plansCancelAddonConfirmWithPromos(
                toDeactivate.length, _labelOf(context))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(context).plansNo)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context).plansYesCancel),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await cubit.cancelAddon(id, deactivatePromoIds: toDeactivate);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:         Text(AppLocalizations.of(context).plansAddonCancelled),
          backgroundColor: Colors.green.shade700,
          behavior:        SnackBarBehavior.floating,
        ));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:  Text(AppLocalizations.of(context).plansCancelError),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  /// Diálogo para elegir EXACTAMENTE [need] promociones a desactivar.
  Future<List<String>?> _chooseToDeactivate(
      BuildContext context, List<Map<String, dynamic>> promos, int need) {
    final selected = <String>{};
    return showDialog<List<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(
              AppLocalizations.of(context).plansDeactivateDialogTitle(need)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)
                      .plansDeactivateDialogBody(need),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: promos.map((p) {
                      final pid      = p['id'] as String;
                      final checked  = selected.contains(pid);
                      final disabled = !checked && selected.length >= need;
                      return CheckboxListTile(
                        value:    checked,
                        dense:    true,
                        title:    Text(
                            p['name'] as String? ??
                                AppLocalizations.of(context).plansPromoFallback,
                            style: const TextStyle(fontSize: 13)),
                        onChanged: disabled ? null : (v) => setSt(() {
                          (v == true) ? selected.add(pid) : selected.remove(pid);
                        }),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLocalizations.of(context).plansCancel)),
            TextButton(
              onPressed: selected.length == need
                  ? () => Navigator.pop(ctx, selected.toList())
                  : null,
              child: Text(AppLocalizations.of(context).plansContinue),
            ),
          ],
        ),
      ),
    );
  }
}
