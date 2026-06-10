import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:promofy/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/characteristic_model.dart';
import '../../../data/models/establishment_model.dart';
import '../../../data/models/membership_plan_model.dart';
import '../../../data/models/notification_log_model.dart';
import '../../../data/models/promotion_model.dart';
import '../../../data/models/staff_member_model.dart';
import '../../../data/repositories/ads_repository.dart';
import '../../../data/repositories/business_repository.dart';
import '../../../data/repositories/categories_repository.dart';
import '../../../data/repositories/notifications_repository.dart';
import '../../../data/repositories/staff_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../cubit/business_ads_cubit.dart';
import '../cubit/business_ads_state.dart';
import '../cubit/business_cubit.dart';
import '../cubit/business_state.dart';
import 'promo_form_screen.dart';
import 'register_business_screen.dart';
import '../widgets/photos_section.dart';
import '../widgets/stats_section.dart';
import '../../loyalty/cubit/loyalty_cubit.dart';
import '../../loyalty/screens/qr_scanner_screen.dart';
import '../../loyalty/widgets/loyalty_section.dart';
import '../../home/screens/promo_detail_screen.dart';
import '../../../data/repositories/loyalty_repository.dart';
import '../../plans/screens/plans_screen.dart';
import 'admin_metrics_screen.dart';

class BusinessTabScreen extends StatefulWidget {
  const BusinessTabScreen({super.key});

  @override
  State<BusinessTabScreen> createState() => _BusinessTabScreenState();
}

class _BusinessTabScreenState extends State<BusinessTabScreen> {
  @override
  void initState() {
    super.initState();
    // Staff users don't own establishments — skip the owner business load.
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated || !auth.profile.isStaff) {
      context.read<BusinessCubit>().load();
    }
  }

  void _openPromoForm({PromotionModel? promo}) {
    final s = context.read<BusinessCubit>().state;
    if (s is! BusinessLoaded) return;

    // Si es nueva, verifica el límite efectivo (plan + add-ons)
    if (promo == null) {
      final max = s.maxPromotionsEffective;
      if (s.totalPromoCount >= max) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).bizPromoLimitReached(max)),
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BusinessCubit>(),
          child: PromoFormScreen(
            existing:          promo,
            establishmentName: s.selected.name,
          ),
        ),
      ),
    );
  }

  void _openRegister({EstablishmentModel? establishment}) {
    // Si es creación nueva, verifica límite del plan
    if (establishment == null) {
      final s = context.read<BusinessCubit>().state;
      if (s is BusinessLoaded) {
        final max = s.maxEstablishmentsEffective;
        if (s.establishments.length >= max) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)
                  .bizEstablishmentLimitReached(s.plan?.name ?? "", max)),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BusinessCubit>(),
          child: RegisterBusinessScreen(establishment: establishment),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;

    // ── Admin mode: panel de métricas globales de la plataforma ───────────
    if (auth is AuthAuthenticated && auth.profile.role == 'admin') {
      return const AdminMetricsScreen();
    }

    // ── Staff mode: show limited manager view ──────────────────────────────
    if (auth is AuthAuthenticated && auth.profile.isStaff) {
      return const _StaffBusinessView();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context).bizMyBusiness,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<BusinessCubit, BusinessState>(
        listener: (context, state) {
          if (state is BusinessError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:         Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior:        SnackBarBehavior.floating,
              ),
            );
            context.read<BusinessCubit>().clearError();
          }
        },
        builder: (context, state) {
          if (state is BusinessInitial ||
              state is BusinessLoading ||
              state is BusinessSaving) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BusinessLoaded) {
            return _LoadedBody(
              state:                state,
              onEditEstablishment:  (est)  => _openRegister(establishment: est),
              onAddEstablishment:   ()     => _openRegister(),
              onAddPromo:           ()     => _openPromoForm(),
              onEditPromo:          (promo)=> _openPromoForm(promo: promo),
            );
          }
          // BusinessNoEstablishment y Error
          final plan = state is BusinessNoEstablishment ? state.plan : null;
          return _EmptyState(
            plan:       plan,
            onRegister: () => _openRegister(),
          );
        },
      ),
    );
  }
}

// ─── Vista: establecimientos cargados ────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  final BusinessLoaded state;
  final void Function(EstablishmentModel) onEditEstablishment;
  final VoidCallback                      onAddEstablishment;
  final VoidCallback                      onAddPromo;
  final void Function(PromotionModel)     onEditPromo;

  const _LoadedBody({
    required this.state,
    required this.onEditEstablishment,
    required this.onAddEstablishment,
    required this.onAddPromo,
    required this.onEditPromo,
  });

  @override
  Widget build(BuildContext context) {
    final est = state.selected;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Barra de uso del plan ─────────────────────────────────────────
          if (state.plan != null)
            _PlanUsageBar(
              plan:       state.plan!,
              estCount:   state.establishments.length,
              promoCount: state.totalPromoCount,
              maxEst:     state.maxEstablishmentsEffective,
              maxPromos:  state.maxPromotionsEffective,
            ),
          if (state.plan != null) const SizedBox(height: 12),

          // ── Selector de establecimientos ──────────────────────────────────
          _EstablishmentSelector(
            establishments: state.establishments,
            selectedIndex:  state.selectedIndex,
            plan:           state.plan,
            onSelect:       (i) => context.read<BusinessCubit>().selectEstablishment(i),
            onAdd:          onAddEstablishment,
          ),
          const SizedBox(height: 16),

          // ── Detalle del establecimiento seleccionado ──────────────────────
          _InfoCard(establishment: est),
          const SizedBox(height: 16),

          // _DetailsCard solo se incluye cuando hay contenido real;
          // evitar SizedBox.shrink() 0×0 que dispara mouse_tracker assert.
          if (est.establishmentType != null ||
              est.categoryId != null ||
              est.paymentMethods.isNotEmpty ||
              est.adultPromotions) ...[
            _DetailsCard(establishment: est),
            const SizedBox(height: 16),
          ],

          if (est.schedule != null && est.schedule!.isNotEmpty) ...[
            _ScheduleCard(schedule: est.schedule),
            const SizedBox(height: 16),
          ],

          PhotosSection(establishment: est),
          const SizedBox(height: 16),

          // ── Programa de lealtad ───────────────────────────────────────────
          LoyaltySection(establishment: est),
          const SizedBox(height: 16),

          _PromosSection(
            promos:       state.promos,
            promosLoaded: state.promosLoaded,
            maxPromos:    state.plan == null ? null : state.maxPromotionsEffective,
            totalUsed:    state.totalPromoCount,
            canAdd:       state.plan == null ||
                state.totalPromoCount < state.maxPromotionsEffective,
            onAdd:        onAddPromo,
            onEdit:       onEditPromo,
          ),
          const SizedBox(height: 16),

          _StaffSection(establishmentId: est.id),
          const SizedBox(height: 16),

          _AdsSection(establishmentId: est.id),
          const SizedBox(height: 16),

          _NotifStatsSection(
            establishmentId: est.id,
            promoCount:      state.promos.length,
          ),
          const SizedBox(height: 16),

          if (state.isSubscriptionActive)
            StatsSection(establishmentId: est.id)
          else
            const _SubscriptionGate(),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () => onEditEstablishment(est),
            icon:      const Icon(Icons.edit_outlined),
            label:     Text(AppLocalizations.of(context).bizEditInfo),
            style: OutlinedButton.styleFrom(
              minimumSize:  const Size(double.infinity, 52),
              side:         const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Candado de estadísticas (sin suscripción activa) ────────────────────────

class _SubscriptionGate extends StatelessWidget {
  const _SubscriptionGate();

  @override
  Widget build(BuildContext context) {
    return Container(
      width:       double.infinity,
      padding:     const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration:  BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding:    const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:  AppColors.primary.withAlpha(20),
              shape:  BoxShape.circle,
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              size:  32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).bizStatsTitle,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).bizStatsGateDesc,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PlansScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:  AppColors.primary,
              foregroundColor:  Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Text(AppLocalizations.of(context).bizViewPlans),
          ),
        ],
      ),
    );
  }
}

// ─── Barra de uso del plan ────────────────────────────────────────────────────

class _PlanUsageBar extends StatelessWidget {
  final MembershipPlanModel plan;
  final int                 estCount;
  final int                 promoCount;
  final int                 maxEst;
  final int                 maxPromos;

  const _PlanUsageBar({
    required this.plan,
    required this.estCount,
    required this.promoCount,
    required this.maxEst,
    required this.maxPromos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withAlpha(10),
              blurRadius: 6,
              offset:     const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            plan.name,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          _UsagePill(current: estCount,   max: maxEst,    label: AppLocalizations.of(context).bizUsageBusinesses),
          const SizedBox(width: 6),
          _UsagePill(current: promoCount, max: maxPromos, label: AppLocalizations.of(context).bizUsagePromos),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PlansScreen()),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize:   Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.secondary,
            ),
            child: Text(AppLocalizations.of(context).bizUpgrade, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _UsagePill extends StatelessWidget {
  final int    current;
  final int    max;
  final String label;

  const _UsagePill({required this.current, required this.max, required this.label});

  @override
  Widget build(BuildContext context) {
    final atLimit = current >= max;
    final color   = atLimit ? Colors.red.shade600 : AppColors.textDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color:        (atLimit ? Colors.red : Colors.grey).withAlpha(15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$current/$max $label',
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }
}

// ─── Selector de establecimientos ────────────────────────────────────────────

class _EstablishmentSelector extends StatelessWidget {
  final List<EstablishmentModel> establishments;
  final int                      selectedIndex;
  final MembershipPlanModel?     plan;
  final void Function(int)       onSelect;
  final VoidCallback             onAdd;

  const _EstablishmentSelector({
    required this.establishments,
    required this.selectedIndex,
    required this.plan,
    required this.onSelect,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final canAdd = plan == null ||
        establishments.length < plan!.maxEstablishments;

    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < establishments.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _EstChip(
                name:     establishments[i].name,
                selected: i == selectedIndex,
                onTap:    () => onSelect(i),
              ),
            ],
            const SizedBox(width: 8),
            _AddEstChip(canAdd: canAdd, onTap: onAdd),
          ],
        ),
      ),
    );
  }
}

class _EstChip extends StatelessWidget {
  final String       name;
  final bool         selected;
  final VoidCallback onTap;

  const _EstChip({required this.name, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:        selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.primary.withAlpha(40), blurRadius: 6)]
              : [],
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w500,
            color:      selected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

class _AddEstChip extends StatelessWidget {
  final bool         canAdd;
  final VoidCallback onTap;

  const _AddEstChip({required this.canAdd, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:        canAdd
              ? AppColors.primary.withAlpha(12)
              : Colors.grey.withAlpha(15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: canAdd
                ? AppColors.primary.withAlpha(80)
                : Colors.grey.withAlpha(60),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size:  14,
              color: canAdd ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context).bizAdd,
              style: TextStyle(
                fontSize:   12,
                color:      canAdd ? AppColors.primary : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta: información de contacto ─────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final EstablishmentModel establishment;
  const _InfoCard({required this.establishment});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    if (establishment.address != null && establishment.address!.isNotEmpty) {
      rows.add(_InfoRow(icon: Icons.location_on_outlined, text: establishment.address!));
    }
    if (establishment.phone != null && establishment.phone!.isNotEmpty) {
      rows.add(_InfoRow(icon: Icons.phone_outlined, text: establishment.phone!));
    }
    if (establishment.website != null && establishment.website!.isNotEmpty) {
      rows.add(_InfoRow(
          icon: Icons.language_outlined,
          text: establishment.website!,
          url:  establishment.website));
    }
    if (establishment.facebookUrl != null && establishment.facebookUrl!.isNotEmpty) {
      rows.add(_InfoRow(
          icon: Icons.facebook_outlined,
          text: establishment.facebookUrl!,
          url:  establishment.facebookUrl));
    }
    if (establishment.instagramUrl != null && establishment.instagramUrl!.isNotEmpty) {
      rows.add(_InfoRow(
          icon: Icons.camera_alt_outlined,
          text: establishment.instagramUrl!,
          url:  establishment.instagramUrl));
    }
    if (establishment.description != null && establishment.description!.isNotEmpty) {
      rows.add(_InfoRow(icon: Icons.info_outline, text: establishment.description!));
    }

    if (rows.isEmpty) {
      rows.add(Text(AppLocalizations.of(context).bizNoExtraInfo,
          style: const TextStyle(color: Colors.grey)));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).bizBusinessInfo,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   text;
  final String?  url;
  const _InfoRow({required this.icon, required this.text, this.url});

  Future<void> _open() async {
    if (url == null) return;
    final uri = Uri.tryParse(url!);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isLink = url != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap:        isLink ? _open : null,
        borderRadius: BorderRadius.circular(6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18,
                color: isLink ? AppColors.primary : Colors.grey.shade500),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                    fontSize:   14,
                    color:      isLink ? AppColors.primary : AppColors.textDark,
                    decoration: isLink ? TextDecoration.underline : null,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta: detalles (tipo, categoría, características, pagos) ──────────────

class _DetailsCard extends StatefulWidget {
  final EstablishmentModel establishment;
  const _DetailsCard({required this.establishment});

  @override
  State<_DetailsCard> createState() => _DetailsCardState();
}

class _DetailsCardState extends State<_DetailsCard> {
  String?  _categoryName;
  List<CharacteristicModel> _characteristics = [];
  bool     _loading = true;

  static String _typeLabel(BuildContext context, String key) {
    final l = AppLocalizations.of(context);
    switch (key) {
      case 'local':        return l.bizTypeLocal;
      case 'urban_mobile': return l.bizTypeUrbanMobile;
      default:             return key;
    }
  }
  static const _typeIcons = {
    'local':        Icons.storefront_outlined,
    'urban_mobile': Icons.directions_car_outlined,
  };
  static String _paymentLabel(BuildContext context, String key) {
    final l = AppLocalizations.of(context);
    switch (key) {
      case 'card':  return l.bizPaymentCard;
      case 'cash':  return l.bizPaymentCash;
      case 'other': return l.bizPaymentOther;
      default:      return key;
    }
  }
  static const _paymentIcons = {
    'card':  Icons.credit_card_outlined,
    'cash':  Icons.payments_outlined,
    'other': Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void didUpdateWidget(_DetailsCard old) {
    super.didUpdateWidget(old);
    if (old.establishment.id != widget.establishment.id) {
      setState(() => _loading = true);
      _loadDetails();
    }
  }

  Future<void> _loadDetails() async {
    try {
      final repo  = CategoriesRepository();
      final catId = widget.establishment.categoryId;
      final results = await Future.wait([
        catId != null ? repo.getCategoryById(catId) : Future.value(null),
        repo.getCharacteristicsByEstablishment(widget.establishment.id),
      ]);
      if (mounted) {
        setState(() {
          _categoryName    = (results[0] as dynamic)?.name as String?;
          _characteristics = results[1] as List<CharacteristicModel>;
          _loading         = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final est         = widget.establishment;
    final hasType     = est.establishmentType != null;
    final hasCategory = est.categoryId != null;
    final hasChars    = !_loading && _characteristics.isNotEmpty;
    final hasPayments = est.paymentMethods.isNotEmpty;
    final hasAdult    = est.adultPromotions;

    if (!hasType && !hasCategory && !hasPayments && !hasAdult) {
      return const SizedBox.shrink();
    }

    final sections = <Widget>[];

    // Tipo • Categoría
    if (hasType || hasCategory) {
      sections.add(Row(
        children: [
          if (hasType) ...[
            Icon(_typeIcons[est.establishmentType] ?? Icons.store_outlined,
                size: 15, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(_typeLabel(context, est.establishmentType!),
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
          ],
          if (hasType && hasCategory)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('·', style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
            ),
          if (_loading && hasCategory)
            const SizedBox(width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 2))
          else if (_categoryName != null)
            _InfoChip(label: _categoryName!, color: AppColors.primary),
        ],
      ));
    }

    // Características
    if (hasChars) {
      if (sections.isNotEmpty) sections.add(const Divider(height: 20, color: Color(0xFFEEEEEE)));
      sections.add(Wrap(
        spacing: 6, runSpacing: 6,
        children: _characteristics
            .map((c) => _InfoChip(label: c.localizedName(Localizations.localeOf(context).languageCode), color: AppColors.secondary))
            .toList(),
      ));
    }

    // Pagos
    if (hasPayments) {
      if (sections.isNotEmpty) sections.add(const Divider(height: 20, color: Color(0xFFEEEEEE)));
      sections.add(Wrap(
        spacing: 16, runSpacing: 6,
        children: est.paymentMethods.map((key) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_paymentIcons[key] ?? Icons.payment_outlined,
                size: 14, color: Colors.green.shade700),
            const SizedBox(width: 5),
            Text(_paymentLabel(context, key),
                style: TextStyle(fontSize: 13, color: Colors.green.shade800)),
          ],
        )).toList(),
      ));
    }

    // Adultos
    if (hasAdult) {
      if (sections.isNotEmpty) sections.add(const Divider(height: 20, color: Color(0xFFEEEEEE)));
      sections.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.no_adult_content, size: 15, color: Colors.orange.shade700),
          const SizedBox(width: 6),
          Text(AppLocalizations.of(context).bizAdultPromotions,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w500)),
        ],
      ));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sections),
    );
  }
}

// ─── Tarjeta: horario ─────────────────────────────────────────────────────────

class _ScheduleCard extends StatelessWidget {
  final Map<String, dynamic>? schedule;
  const _ScheduleCard({required this.schedule});

  static const _dayOrder = [
    'monday','tuesday','wednesday','thursday','friday','saturday','sunday',
  ];
  static String _dayLabel(BuildContext context, String key) {
    final l = AppLocalizations.of(context);
    switch (key) {
      case 'monday':    return l.bizDayMonday;
      case 'tuesday':   return l.bizDayTuesday;
      case 'wednesday': return l.bizDayWednesday;
      case 'thursday':  return l.bizDayThursday;
      case 'friday':    return l.bizDayFriday;
      case 'saturday':  return l.bizDaySaturday;
      case 'sunday':    return l.bizDaySunday;
      default:          return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (schedule == null || schedule!.isEmpty) return const SizedBox.shrink();
    final days = _dayOrder.where((d) => schedule!.containsKey(d)).toList();
    if (days.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.access_time_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).bizScheduleTitle,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ]),
          const SizedBox(height: 12),
          for (final day in days) _buildDayRow(context, day, schedule![day]),
        ],
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, String day, dynamic data) {
    final label  = _dayLabel(context, day);
    final closed = data is Map && data['closed'] == true;
    final open   = data is Map ? (data['open']  as String? ?? '') : '';
    final close  = data is Map ? (data['close'] as String? ?? '') : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
          ),
          if (closed)
            Text(AppLocalizations.of(context).bizClosed, style: TextStyle(fontSize: 13, color: Colors.grey.shade500))
          else ...[
            Text(open,  style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
            Text(' – ', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
            Text(close, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
          ],
        ],
      ),
    );
  }
}

// ─── Sección: Mis Promociones ─────────────────────────────────────────────────

class _PromosSection extends StatelessWidget {
  final List<PromotionModel>          promos;
  final bool                          promosLoaded;
  final int?                          maxPromos;
  final int                           totalUsed;
  final bool                          canAdd;
  final VoidCallback                  onAdd;
  final void Function(PromotionModel) onEdit;
  /// Callback para activar/desactivar "destacada".
  /// null = usa BusinessCubit (vista del dueño).
  /// Provisto = modo staff con manage_promos.
  final void Function(String)?        onToggleFeatured;
  /// false = oculta el switch de destacada (staff sin manage_promos).
  final bool                          showFeaturedToggle;

  const _PromosSection({
    required this.promos,
    required this.promosLoaded,
    this.maxPromos,
    this.totalUsed = 0,
    required this.canAdd,
    required this.onAdd,
    required this.onEdit,
    this.onToggleFeatured,
    this.showFeaturedToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(AppLocalizations.of(context).bizMyPromos,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ),
              if (maxPromos != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:        (totalUsed >= maxPromos! ? Colors.red : Colors.grey)
                        .withAlpha(15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalUsed/$maxPromos',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: totalUsed >= maxPromos!
                          ? Colors.red.shade700
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              // Botón "+" — visible siempre; si no puede agregar se muestra opaco
              GestureDetector(
                onTap: canAdd ? onAdd : null,
                child: Opacity(
                  opacity: canAdd ? 1.0 : 0.35,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color:        AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, size: 18, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).bizFeaturedHint,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 12),
          if (!promosLoaded)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          else if (promos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(AppLocalizations.of(context).bizNoPromosYet,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            )
          else
            ...promos.map((p) => _PromoToggleRow(
              promo:              p,
              onEdit:             onEdit,
              onToggleFeatured:   onToggleFeatured,
              showFeaturedToggle: showFeaturedToggle,
            )),

          // ── Comprar espacio cuando se llegó al límite de promos ──────────
          if (maxPromos != null && totalUsed >= maxPromos!) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:        AppColors.primary.withAlpha(12),
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: AppColors.primary.withAlpha(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).bizPlanLimitTitle,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(AppLocalizations.of(context).bizBuyExtraSpaceDesc,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PlansScreen()),
                      ),
                      icon:  const Icon(Icons.add_business_outlined, size: 18),
                      label: Text(AppLocalizations.of(context).bizBuyPromoSpace,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PromoToggleRow extends StatelessWidget {
  final PromotionModel               promo;
  final void Function(PromotionModel) onEdit;
  /// null = usar BusinessCubit (vista del dueño).
  /// Provisto = modo staff con manage_promos.
  final void Function(String)?        onToggleFeatured;
  /// false = ocultar el switch de destacada.
  final bool                          showFeaturedToggle;

  const _PromoToggleRow({
    required this.promo,
    required this.onEdit,
    this.onToggleFeatured,
    this.showFeaturedToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    final isFeatured = promo.isFeatured;
    final isFlash    = promo.type == 'flash';
    final isLocked   = promo.isLocked;

    void handleEditTap() {
      if (isLocked) {
        final until = promo.lockedUntil;
        final msg   = until != null
            ? AppLocalizations.of(context).bizEditAvailableOn(
                DateFormat("d 'de' MMMM", "es_MX").format(until))
            : AppLocalizations.of(context).bizPromoNotEditableYet;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:  Text(msg),
          behavior: SnackBarBehavior.floating,
        ));
      } else {
        onEdit(promo);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isFeatured
              ? const Color(0xFFFFB300).withAlpha(15)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFeatured
                ? const Color(0xFFFFB300).withAlpha(120)
                : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          children: [
            // Área tappable → abre formulario de edición (bloqueada 15 días)
            Expanded(
              child: InkWell(
                onTap:        handleEditTap,
                borderRadius: const BorderRadius.only(
                  topLeft:    Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                  child: Row(
                    children: [
                      Icon(
                        isFlash ? Icons.bolt : Icons.local_offer,
                        size:  16,
                        color: isFeatured
                            ? const Color(0xFFFFB300)
                            : (isFlash
                                ? AppColors.secondary
                                : Colors.grey.shade400),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(promo.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textDark)),
                            if (isLocked) ...[
                              const SizedBox(height: 2),
                              Row(children: [
                                Icon(Icons.lock_outline, size: 11,
                                    color: Colors.orange.shade600),
                                const SizedBox(width: 3),
                                Text(
                                  promo.lockedUntil != null
                                      ? AppLocalizations.of(context).bizEditableOn(
                                          DateFormat("d MMM", "es_MX").format(promo.lockedUntil!))
                                      : AppLocalizations.of(context).bizLocked,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w600),
                                ),
                              ]),
                            ] else if (isFeatured) ...[
                              const SizedBox(height: 2),
                              Row(children: [
                                const Icon(Icons.star, size: 11,
                                    color: Color(0xFFFFB300)),
                                const SizedBox(width: 3),
                                Text(AppLocalizations.of(context).bizFeatured,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFFFB300),
                                        fontWeight: FontWeight.w600)),
                              ]),
                            ] else if (isFlash) ...[
                              const SizedBox(height: 2),
                              Text(AppLocalizations.of(context).bizFlash,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ],
                        ),
                      ),
                      // Ícono de candado cuando está bloqueada, flecha si no
                      if (isLocked)
                        Icon(Icons.lock_outline,
                            size: 16, color: Colors.orange.shade400)
                      else
                        const Icon(Icons.chevron_right,
                            size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            // Switch de destacada (no propaga el tap al InkWell)
            if (showFeaturedToggle)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Switch.adaptive(
                  value:     isFeatured,
                  onChanged: (_) {
                    if (onToggleFeatured != null) {
                      onToggleFeatured!(promo.id);
                    } else {
                      context.read<BusinessCubit>().toggleFeatured(promo.id);
                    }
                  },
                  activeColor:           const Color(0xFFFFB300),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers visuales ─────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  final Color  color;
  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withAlpha(80)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

BoxDecoration get _cardDecoration => BoxDecoration(
      color:        Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color:      Colors.black.withAlpha(13),
            blurRadius: 8,
            offset:     const Offset(0, 2)),
      ],
    );

// ─── Sección: Mi equipo (staff) ──────────────────────────────────────────────

class _StaffSection extends StatefulWidget {
  final String establishmentId;
  const _StaffSection({required this.establishmentId});

  @override
  State<_StaffSection> createState() => _StaffSectionState();
}

class _StaffSectionState extends State<_StaffSection> {
  final _repo = StaffRepository();
  bool   _loading = true;
  List<StaffMemberModel> _staff = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_StaffSection old) {
    super.didUpdateWidget(old);
    if (old.establishmentId != widget.establishmentId) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _repo.getStaff(widget.establishmentId);
      if (mounted) setState(() { _staff = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(StaffMemberModel m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context).bizRemoveFromTeamTitle),
        content: Text(AppLocalizations.of(context).bizRemoveFromTeamConfirm(m.displayName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context).bizCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).bizRemove, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _repo.removeStaff(widget.establishmentId, m.userId);
      if (mounted) setState(() => _staff.removeWhere((s) => s.id == m.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).bizRemoveTeamError(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _openInvite() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _InviteSheet(
        establishmentId: widget.establishmentId,
        repo:            _repo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width:      double.infinity,
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.groups_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(AppLocalizations.of(context).bizMyTeam,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                ),
                if (_loading)
                  const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                else
                  GestureDetector(
                    onTap: _load,
                    child: Icon(Icons.refresh_rounded, size: 18, color: Colors.grey.shade400),
                  ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: _openInvite,
                  icon:  const Icon(Icons.person_add_outlined, size: 16),
                  label: Text(AppLocalizations.of(context).bizInvite, style: const TextStyle(fontSize: 13)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize:   Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary)),
            )
          else if (_staff.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.group_add_outlined, size: 36, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context).bizNoStaffYet,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.5)),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
              child: Column(
                children: _staff.map((m) => _StaffRow(
                  member:   m,
                  onRemove: () => _remove(m),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _StaffRow extends StatelessWidget {
  final StaffMemberModel member;
  final VoidCallback     onRemove;
  const _StaffRow({required this.member, required this.onRemove});

  static const _roleColors = {
    'manager': Color(0xFF00897B),
    'cashier': Color(0xFF1976D2),
    'custom':  Color(0xFF6A1B9A),
  };

  @override
  Widget build(BuildContext context) {
    final color    = _roleColors[member.role] ?? AppColors.primary;
    final initials = member.displayName.trim().split(' ')
        .take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius:          18,
            backgroundColor: color.withAlpha(22),
            child: Text(initials,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                        color: AppColors.textDark)),
                Text(member.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color:        color.withAlpha(18),
              borderRadius: BorderRadius.circular(20),
              border:       Border.all(color: color.withAlpha(60)),
            ),
            child: Text(member.roleLabel,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon:    const Icon(Icons.person_remove_outlined, size: 18),
            color:   Colors.red.shade400,
            onPressed: onRemove,
            tooltip: AppLocalizations.of(context).bizRemoveFromTeamTooltip,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom sheet: invitar empleado ──────────────────────────────────────────

class _InviteSheet extends StatefulWidget {
  final String        establishmentId;
  final StaffRepository repo;
  const _InviteSheet({required this.establishmentId, required this.repo});

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  String _role = 'cashier';
  bool   _permScanQr        = true;
  bool   _permViewStats      = false;
  bool   _permManagePromos   = false;
  bool   _permManagePayments = false;
  bool   _generating = false;

  static const _presets = {
    'manager': {'scan_qr': true,  'view_stats': true,  'manage_promos': true,  'manage_payments': true},
    'cashier': {'scan_qr': true,  'view_stats': false, 'manage_promos': false, 'manage_payments': false},
    'custom':  <String, bool>{},
  };

  Map<String, bool> get _permissions {
    if (_role != 'custom') return Map.from(_presets[_role]!);
    return {
      'scan_qr':        _permScanQr,
      'view_stats':     _permViewStats,
      'manage_promos':  _permManagePromos,
      'manage_payments': _permManagePayments,
    };
  }

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      final code = await widget.repo.createInvitation(
        establishmentId: widget.establishmentId,
        role:            _role,
        permissions:     _permissions,
      );
      if (!mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => _InviteCodeDialog(code: code, role: _role),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).bizGenerateCodeError(e.toString())),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom    = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color:        Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(AppLocalizations.of(context).bizInviteStaff,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context).bizCodeAvailable48h,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 20),

            Text(AppLocalizations.of(context).bizRoleLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                color: Color(0xFF9E9E9E), letterSpacing: 0.6)),
            const SizedBox(height: 10),

            _RoleOption(
              value:    'cashier',
              group:    _role,
              label:    AppLocalizations.of(context).bizRoleCashier,
              subtitle: AppLocalizations.of(context).bizRoleCashierDesc,
              icon:     Icons.qr_code_scanner,
              color:    const Color(0xFF1976D2),
              onChanged: (v) => setState(() => _role = v),
            ),
            const SizedBox(height: 8),
            _RoleOption(
              value:    'manager',
              group:    _role,
              label:    AppLocalizations.of(context).bizRoleManager,
              subtitle: AppLocalizations.of(context).bizRoleManagerDesc,
              icon:     Icons.manage_accounts_outlined,
              color:    const Color(0xFF00897B),
              onChanged: (v) => setState(() => _role = v),
            ),
            const SizedBox(height: 8),
            _RoleOption(
              value:    'custom',
              group:    _role,
              label:    AppLocalizations.of(context).bizRoleCustom,
              subtitle: AppLocalizations.of(context).bizRoleCustomDesc,
              icon:     Icons.tune_outlined,
              color:    const Color(0xFF6A1B9A),
              onChanged: (v) => setState(() => _role = v),
            ),

            if (_role == 'custom') ...[
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context).bizPermissionsLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: Color(0xFF9E9E9E), letterSpacing: 0.6)),
              const SizedBox(height: 6),
              _PermCheck(
                label:    AppLocalizations.of(context).bizPermScanQr,
                value:    _permScanQr,
                onChanged: (v) => setState(() => _permScanQr = v),
              ),
              _PermCheck(
                label:    AppLocalizations.of(context).bizPermViewStats,
                value:    _permViewStats,
                onChanged: (v) => setState(() => _permViewStats = v),
              ),
              _PermCheck(
                label:    AppLocalizations.of(context).bizPermManagePromos,
                value:    _permManagePromos,
                onChanged: (v) => setState(() => _permManagePromos = v),
              ),
              _PermCheck(
                label:    AppLocalizations.of(context).bizPermManagePayments,
                value:    _permManagePayments,
                onChanged: (v) => setState(() => _permManagePayments = v),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generating ? null : _generate,
                icon:  _generating
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.generating_tokens_outlined),
                label: Text(_generating
                    ? AppLocalizations.of(context).bizGenerating
                    : AppLocalizations.of(context).bizGenerateCode),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String   value;
  final String   group;
  final String   label;
  final String   subtitle;
  final IconData icon;
  final Color    color;
  final void Function(String) onChanged;

  const _RoleOption({
    required this.value,
    required this.group,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == group;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:        selected ? color.withAlpha(18) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selected ? color : Colors.grey.shade400),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontSize:   14,
                        fontWeight: FontWeight.w600,
                        color:      selected ? color : AppColors.textDark,
                      )),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Radio<String>(
              value:         value,
              groupValue:    group,
              onChanged:     (v) => onChanged(v!),
              activeColor:   color,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermCheck extends StatelessWidget {
  final String label;
  final bool   value;
  final void Function(bool) onChanged;
  const _PermCheck({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value:           value,
      onChanged:       (v) => onChanged(v ?? false),
      title:           Text(label, style: const TextStyle(fontSize: 14)),
      activeColor:     AppColors.primary,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding:  EdgeInsets.zero,
      dense:           true,
    );
  }
}

// ─── Dialog: código de invitación ────────────────────────────────────────────

class _InviteCodeDialog extends StatelessWidget {
  final String code;
  final String role;
  const _InviteCodeDialog({required this.code, required this.role});

  String _roleLabel(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (role) {
      case 'manager': return l.bizRoleManager;
      case 'cashier': return l.bizRoleCashier;
      default:        return l.bizRoleCustom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context).bizCodeGenerated,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context).bizCodeRole(_roleLabel(context)),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          // Código grande con fondo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color:        AppColors.primary.withAlpha(12),
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(color: AppColors.primary.withAlpha(60)),
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontSize:   32,
                fontWeight: FontWeight.bold,
                color:      AppColors.primary,
                letterSpacing: 6,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context).bizCodeValid48h,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.5)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context).bizCodeCopied),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ));
            },
            icon:  const Icon(Icons.copy, size: 16),
            label: Text(AppLocalizations.of(context).bizCopyCode),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).bizDone),
        ),
      ],
    );
  }
}

// ─── Sección: estadísticas de notificaciones push ────────────────────────────

class _NotifStatsSection extends StatefulWidget {
  final String establishmentId;
  final int    promoCount;
  const _NotifStatsSection({
    required this.establishmentId,
    required this.promoCount,
  });

  @override
  State<_NotifStatsSection> createState() => _NotifStatsSectionState();
}

class _NotifStatsSectionState extends State<_NotifStatsSection> {
  final _repo  = NotificationsRepository();
  int  _days   = 30;
  bool _loading = true;
  List<NotificationLogModel> _logs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_NotifStatsSection old) {
    super.didUpdateWidget(old);
    if (old.establishmentId != widget.establishmentId ||
        old.promoCount      != widget.promoCount) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final logs = await _repo.getEstablishmentLogs(
        widget.establishmentId,
        days: _days,
      );
      if (mounted) setState(() { _logs = logs; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setDays(int days) {
    if (_days == days) return;
    _days = days;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final totalSent   = _logs.fold(0, (s, l) => s + l.sentCount);
    final totalOpens  = _logs.fold(0, (s, l) => s + l.openCount);
    final avgOpenRate = totalSent == 0 ? 0.0 : totalOpens / totalSent * 100;

    return Container(
      width:      double.infinity,
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.notifications_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).bizPushNotifications,
                    style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark,
                    ),
                  ),
                ),
                if (_loading)
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                else
                  GestureDetector(
                    onTap: _load,
                    child: Icon(Icons.refresh_rounded, size: 18, color: Colors.grey.shade400),
                  ),
                const SizedBox(width: 10),
                _PeriodToggle(days: _days, onChanged: _setDays),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary)),
            )
          else if (_logs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.notifications_off_outlined, size: 36, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).bizNoNotifications,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.5),
                  ),
                ],
              ),
            )
          else ...[
            // ── KPIs ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  _NotifKpi(
                    label: AppLocalizations.of(context).bizKpiSent,
                    value: '${_logs.length}',
                    icon:  Icons.send_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _NotifKpi(
                    label: AppLocalizations.of(context).bizKpiReached,
                    value: '$totalSent',
                    icon:  Icons.people_outline,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  _NotifKpi(
                    label: AppLocalizations.of(context).bizKpiOpenRate,
                    value: '${avgOpenRate.toStringAsFixed(1)}%',
                    icon:  Icons.touch_app_outlined,
                    color: Colors.teal.shade400,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.of(context).bizRecentHistory,
                style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: Color(0xFF9E9E9E), letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // ── Lista de notificaciones ─────────────────────────────────────
            ...(_logs.take(8).map((log) => _NotifLogRow(log: log))),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class _NotifKpi extends StatelessWidget {
  final String   label;
  final String   value;
  final IconData icon;
  final Color    color;

  const _NotifKpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color:        color.withAlpha(18),
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _NotifLogRow extends StatelessWidget {
  final NotificationLogModel log;
  const _NotifLogRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final openPct = log.openRate.toStringAsFixed(1);
    final date    = log.createdAt;
    final dateStr = '${date.day}/${date.month}/${date.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.bolt, size: 14, color: AppColors.secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                ),
                Text(
                  AppLocalizations.of(context).bizNotifSentLine(dateStr, log.sentCount),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color:        Colors.teal.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              AppLocalizations.of(context).bizOpenRateShort(openPct),
              style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: Colors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Toggle de período (7 d / 30 d) ──────────────────────────────────────────

class _PeriodToggle extends StatelessWidget {
  final int                  days;
  final void Function(int)   onChanged;
  const _PeriodToggle({required this.days, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height:      30,
      decoration: BoxDecoration(
        color:        Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Tab(label: '7d',  selected: days == 7,  onTap: () => onChanged(7)),
          _Tab(label: '30d', selected: days == 30, onTap: () => onChanged(30)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String       label;
  final bool         selected;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:        selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize:   12,
            fontWeight: FontWeight.w600,
            color:      selected ? Colors.white : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}

// ─── Vista: sin establecimientos ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final MembershipPlanModel? plan;
  final VoidCallback         onRegister;
  const _EmptyState({required this.onRegister, this.plan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color:  AppColors.primary.withAlpha(20),
                shape:  BoxShape.circle,
              ),
              child: const Icon(Icons.store_mall_directory_outlined,
                  size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context).bizBoostBusiness,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            if (plan != null) ...[
              Text(
                AppLocalizations.of(context).bizPlanIncludes(
                    plan!.name, plan!.maxEstablishments, plan!.maxPromotions),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Text(
                AppLocalizations.of(context).bizEmptyTagline,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRegister,
              icon:  const Icon(Icons.add_business_outlined),
              label: Text(AppLocalizations.of(context).bizRegisterMyBusiness,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sección: Publicidad ───────────────────────────────────────────────────────

class _AdsSection extends StatefulWidget {
  final String establishmentId;
  const _AdsSection({required this.establishmentId});

  @override
  State<_AdsSection> createState() => _AdsSectionState();
}

class _AdsSectionState extends State<_AdsSection> {
  static const _adColor = Color(0xFF00838F);

  late BusinessAdsCubit                  _cubit;
  BusinessAdsState                       _adsState = const BusinessAdsInitial();
  StreamSubscription<BusinessAdsState>?  _sub;

  // ── ciclo de vida ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initCubit();
  }

  @override
  void didUpdateWidget(_AdsSection old) {
    super.didUpdateWidget(old);
    if (old.establishmentId != widget.establishmentId) {
      _disposeCubit();
      _initCubit();
    }
  }

  @override
  void dispose() {
    _disposeCubit();
    super.dispose();
  }

  void _initCubit() {
    final auth = context.read<AuthBloc>().state;
    final uid  = auth is AuthAuthenticated ? auth.user.id : '';
    _cubit = BusinessAdsCubit(
      establishmentId: widget.establishmentId,
      userId:          uid,
    );
    _sub = _cubit.stream.listen((s) {
      if (mounted) setState(() => _adsState = s);
    });
    _cubit.load();
    // load() emite BusinessAdsLoading síncronamente antes del primer await;
    // capturamos ese estado para que el primer build ya muestre el spinner.
    _adsState = _cubit.state;
  }

  void _disposeCubit() {
    _sub?.cancel();
    _sub = null;
    _cubit.close();
  }

  void _showCreateCampaign(BusinessAdsLoaded loaded) {
    // BusinessCubit sólo existe en la vista del dueño; en la vista staff no está
    // en el árbol, por lo que usamos try-catch para evitar el crash.
    List<PromotionModel> promos = [];
    try {
      final bizState = context.read<BusinessCubit>().state;
      promos = bizState is BusinessLoaded ? bizState.promos : [];
    } catch (_) {}

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: _CreateCampaignSheet(state: loaded, promotions: promos),
      ),
    );
  }

  void _showTopUp() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: _TopUpSheet(establishmentId: widget.establishmentId),
      ),
    );
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // BlocProvider.value expone _cubit al subárbol (para _ActiveCampaignsList
    // que llama context.read<BusinessAdsCubit>().toggleCampaignStatus).
    // No cierra el cubit al destruirse: la limpieza la hace _disposeCubit().
    return BlocProvider.value(
      value: _cubit,
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    // Mismo patrón que _StaffSection / _NotifStatsSection:
    // Container(width:∞, decoration:card) → Column → header + Divider + body.
    return Container(
      width:      double.infinity,
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize:       MainAxisSize.min,
        children: [
          // ── Header ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.campaign_outlined, size: 20, color: _adColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).bizAdvertising,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold,
                        color: AppColors.textDark),
                  ),
                ),
                if (_adsState is BusinessAdsLoading)
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _adColor),
                  )
                else
                  GestureDetector(
                    onTap: _cubit.load,
                    child: Icon(Icons.refresh_rounded,
                        size: 18, color: Colors.grey.shade400),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // ── Body ─────────────────────────────────────────────────────
          if (_adsState is BusinessAdsLoading || _adsState is BusinessAdsInitial)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: _adColor),
              ),
            )
          else if (_adsState is BusinessAdsError)
            Padding(
              padding: const EdgeInsets.all(12),
              child: _AdErrorBanner(
                message: (_adsState as BusinessAdsError).message,
                onRetry: _cubit.load,
              ),
            )
          else if (_adsState is BusinessAdsLoaded)
            _AdsLoadedBody(
              state:         _adsState as BusinessAdsLoaded,
              adColor:       _adColor,
              onNewCampaign: _showCreateCampaign,
              onTopUp:       _showTopUp,
            ),
        ],
      ),
    );
  }
}

// ── Cuerpo cargado: tarjeta de saldo + campañas + botón ───────────────────────

class _AdsLoadedBody extends StatelessWidget {
  final BusinessAdsLoaded                state;
  final Color                            adColor;
  final void Function(BusinessAdsLoaded) onNewCampaign;
  final VoidCallback                     onTopUp;

  const _AdsLoadedBody({
    required this.state,
    required this.adColor,
    required this.onNewCampaign,
    required this.onTopUp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize:       MainAxisSize.min,
        children: [
          _AdBalanceCard(state: state, onTopUp: onTopUp),
          if (state.walletMxn > 0) ...[
            const SizedBox(height: 12),
            _WalletCreditCard(walletMxn: state.walletMxn),
          ],
          const SizedBox(height: 12),
          _ActiveCampaignsList(state: state),
          if (state.transactions.isNotEmpty) ...[
            const SizedBox(height: 12),
            _TransactionHistory(transactions: state.transactions),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => onNewCampaign(state),
              icon:  const Icon(Icons.add, size: 18),
              label: Text(AppLocalizations.of(context).bizNewCampaign),
              style: OutlinedButton.styleFrom(
                minimumSize:     const Size(0, 48), // SizedBox(width:∞) ya fuerza el ancho completo
                side:            BorderSide(color: adColor),
                foregroundColor: adColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de cartera: aplicar créditos al saldo de este local ───────────────

class _WalletCreditCard extends StatelessWidget {
  final double walletMxn;
  const _WalletCreditCard({required this.walletMxn});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: Color(0xFF2E7D32)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).bizWalletTitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600)),
                Text(fmt.format(walletMxn),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final cubit = context.read<BusinessAdsCubit>();
              showDialog<void>(
                context: context,
                builder: (_) =>
                    _UseWalletDialog(cubit: cubit, walletMxn: walletMxn),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(AppLocalizations.of(context).bizWalletUse,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _UseWalletDialog extends StatefulWidget {
  final BusinessAdsCubit cubit;
  final double           walletMxn;
  const _UseWalletDialog({required this.cubit, required this.walletMxn});

  @override
  State<_UseWalletDialog> createState() => _UseWalletDialogState();
}

class _UseWalletDialogState extends State<_UseWalletDialog> {
  final _ctrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final l = AppLocalizations.of(context);
    final amount = double.tryParse(_ctrl.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      setState(() => _error = l.bizWalletInvalid);
      return;
    }
    if (amount > widget.walletMxn) {
      setState(() => _error = l.bizWalletInsufficient);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() { _saving = true; _error = null; });
    final messenger = ScaffoldMessenger.of(context);
    final res = await widget.cubit.applyWalletCredit(amount);
    if (!mounted) return;
    setState(() => _saving = false);
    if (res['ok'] == true) {
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(
        content:         Text(l.bizWalletApplied),
        backgroundColor: Colors.green.shade700,
        behavior:        SnackBarBehavior.floating,
      ));
    } else {
      setState(() => _error = res['error'] == 'insufficient_wallet'
          ? l.bizWalletInsufficient
          : l.bizWalletError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l   = AppLocalizations.of(context);
    final fmt = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(l.bizWalletDialogTitle,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${l.bizWalletDialogDesc} (${fmt.format(widget.walletMxn)})',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller:   _ctrl,
                  autofocus:    true,
                  enabled:      !_saving,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    hintText:   '0.00',
                    errorText:  _error,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _saving
                    ? null
                    : () => _ctrl.text = widget.walletMxn.toStringAsFixed(2),
                child: Text(l.bizWalletAll),
              ),
            ],
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l.bizWalletCancel),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _apply,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: _saving
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(l.bizWalletApply),
        ),
      ],
    );
  }
}

// ── Balance card ───────────────────────────────────────────────────────────────

class _AdBalanceCard extends StatelessWidget {
  final BusinessAdsLoaded state;
  final VoidCallback      onTopUp;
  const _AdBalanceCard({required this.state, required this.onTopUp});

  @override
  Widget build(BuildContext context) {
    final fmt     = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final balance = state.credit?.balanceMxn ?? 0.0;
    final reach   = state.estimatedReach('banner');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00838F), Color(0xFF006064)],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).bizAvailableCredit,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(fmt.format(balance),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                if (reach > 0) ...[
                  const SizedBox(height: 6),
                  Text(AppLocalizations.of(context).bizReachableBanner(reach),
                      style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ],
            ),
          ),
          // En iOS NO se muestra la recarga (regla 3.1.1 de Apple: cobros de
          // bienes digitales deben ir por IAP). El dueño recarga desde la web.
          if (!Platform.isIOS)
            ElevatedButton(
              onPressed: onTopUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF006064),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                minimumSize: Size.zero, // override theme's Size(∞, 52) — button is inside a Row
              ),
              child: Text(AppLocalizations.of(context).bizTopUp,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

// ── Lista de campañas activas/pausadas ────────────────────────────────────────

class _ActiveCampaignsList extends StatelessWidget {
  final BusinessAdsLoaded state;
  const _ActiveCampaignsList({required this.state});

  @override
  Widget build(BuildContext context) {
    final fmt       = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final campaigns = state.activeCampaigns;

    if (campaigns.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.campaign_outlined, color: Colors.grey, size: 20),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context).bizNoActiveCampaigns,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).bizOngoingCampaigns,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        ...campaigns.map((c) {
          final statusColor = c.isActive ? Colors.green : Colors.orange;
          return Card(
            margin:    const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(c.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:        statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(c.statusLabel,
                            style: TextStyle(
                                fontSize: 11, color: statusColor,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${c.formatLabel} · ${c.geoModeLabel} · ${c.radiusKm} km',
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value:           c.spentPct,
                      backgroundColor: Colors.grey.shade200,
                      color:           const Color(0xFF00838F),
                      minHeight:       6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context).bizSpent(fmt.format(c.spentMxn)),
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(AppLocalizations.of(context).bizBudget(fmt.format(c.budgetMxn)),
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () =>
                          context.read<BusinessAdsCubit>().toggleCampaignStatus(c),
                      icon: Icon(
                          c.isActive
                              ? Icons.pause_outlined
                              : Icons.play_arrow_outlined,
                          size: 16),
                      label: Text(c.isActive
                          ? AppLocalizations.of(context).bizPause
                          : AppLocalizations.of(context).bizResume,
                          style: const TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF00838F),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Historial de transacciones ─────────────────────────────────────────────────

class _TransactionHistory extends StatefulWidget {
  final List transactions;
  const _TransactionHistory({required this.transactions});

  @override
  State<_TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<_TransactionHistory> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final fmt     = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final dateFmt = DateFormat('dd MMM yyyy', 'es_MX');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              Text(AppLocalizations.of(context).bizTransactionHistory,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey),
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          ...widget.transactions.take(10).map((txn) {
            final isCredit = (txn.amountMxn as double) > 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(
                      isCredit
                          ? Icons.add_circle_outline
                          : Icons.remove_circle_outline,
                      size:  16,
                      color: isCredit ? Colors.green : Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(txn.typeLabel as String,
                            style: const TextStyle(fontSize: 13)),
                        Text(dateFmt.format(txn.createdAt as DateTime),
                            style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text(
                    '${isCredit ? '+' : ''}${fmt.format(txn.amountMxn)}',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isCredit ? Colors.green : Colors.red,
                        fontSize: 13),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

// ── Error banner ───────────────────────────────────────────────────────────────

class _AdErrorBanner extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;
  const _AdErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: const TextStyle(fontSize: 12, color: Colors.red))),
          TextButton(onPressed: onRetry, child: Text(AppLocalizations.of(context).bizRetry)),
        ],
      ),
    );
  }
}

// ── Selector de promoción en la hoja de campaña ───────────────────────────────

class _PromoPickerRow extends StatelessWidget {
  final PromotionModel promo;
  final bool           selected;
  final VoidCallback   onTap;
  const _PromoPickerRow({
    required this.promo,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF00838F);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin:  const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:        selected ? color.withOpacity(0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              promo.isFlash ? Icons.bolt : Icons.local_offer,
              size:  16,
              color: selected ? color : Colors.grey.shade400,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                promo.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w500,
                  color:      selected ? color : AppColors.textDark,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, size: 18, color: color)
            else
              const Icon(Icons.circle_outlined, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ── Hoja: crear campaña ────────────────────────────────────────────────────────

class _CreateCampaignSheet extends StatefulWidget {
  final BusinessAdsLoaded        state;
  final List<PromotionModel>     promotions;
  const _CreateCampaignSheet({required this.state, required this.promotions});

  @override
  State<_CreateCampaignSheet> createState() => _CreateCampaignSheetState();
}

class _CreateCampaignSheetState extends State<_CreateCampaignSheet> {
  final _nameCtrl   = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _adsRepo    = AdsRepository();

  // ── Feature #1: Tipo de anuncio ───────────────────────────────────────────
  String _adType = 'establishment'; // 'establishment' | 'promotion'

  // ── Feature #2: Placements ────────────────────────────────────────────────
  // Placements visuales ('splash' | 'featured_list' | 'banner')
  Set<String> _placements = {'splash', 'featured_list'};
  // Formato especial mutuamente exclusivo con placements visuales
  String? _specialFormat; // null | 'push' | 'flash'

  // Formato efectivo para billing (derivado de placements o specialFormat)
  String get _effectiveFormat {
    if (_specialFormat != null) return _specialFormat!;
    if (_placements.contains('splash'))        return 'splash';
    if (_placements.contains('featured_list')) return 'featured_list';
    if (_placements.contains('banner'))        return 'banner';
    return 'splash';
  }

  // Placements a guardar en DB
  List<String> get _effectivePlacements {
    if (_specialFormat != null) return [_specialFormat!];
    return _placements.toList();
  }

  String      _geoMode       = 'both';
  int         _radiusKm      = 5;
  bool        _saving        = false;
  String?     _error;

  // ── Segmentación demográfica ───────────────────────────────────────────────
  RangeValues _ageRange      = const RangeValues(18, 80);
  String      _gender        = 'all';   // 'all' | 'male' | 'female'
  int?        _reachPool;               // audiencia potencial (async)
  bool        _fetchingReach = false;
  Timer?      _reachDebounce;
  String?     _selectedPromoId;        // promo ligada a la campaña (cuando _adType == 'promotion')

  static const _geoModeKeys = <String>[
    'both',
    'physical_location',
    'search_area',
  ];

  static String _geoModeLabel(BuildContext context, String key) {
    final l = AppLocalizations.of(context);
    switch (key) {
      case 'both':              return l.bizGeoBoth;
      case 'physical_location': return l.bizGeoPhysical;
      case 'search_area':       return l.bizGeoSearchArea;
      default:                  return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshReach(); // estimación inicial con valores por defecto
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _budgetCtrl.dispose();
    _reachDebounce?.cancel();
    super.dispose();
  }

  /// Consulta Supabase con debounce para contar la audiencia elegible.
  void _refreshReach() {
    _reachDebounce?.cancel();
    _reachDebounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => _fetchingReach = true);
      try {
        final count = await _adsRepo.getReachEstimate(
          minAge: _ageRange.start.round(),
          maxAge: _ageRange.end.round(),
          gender: _gender,
        );
        if (mounted) setState(() { _reachPool = count; _fetchingReach = false; });
      } catch (_) {
        if (mounted) setState(() => _fetchingReach = false);
      }
    });
  }

  int _estimatedReach() {
    final budget = double.tryParse(_budgetCtrl.text.replaceAll(',', '.'));
    if (budget == null || budget <= 0) return 0;
    final pricing = widget.state.pricing
        .where((p) => p.format == _effectiveFormat)
        .firstOrNull;
    if (pricing == null || pricing.priceMxn <= 0) return 0;
    final unit = pricing.effectiveBillingUnit(widget.state.totalUserCount);
    return ((budget / pricing.priceMxn) * unit).floor();
  }

  double _minBudget() {
    final p = widget.state.pricing.where((x) => x.format == _effectiveFormat).firstOrNull;
    return p?.minBudgetMxn ?? 0;
  }

  Future<void> _save() async {
    final name   = _nameCtrl.text.trim();
    final budget = double.tryParse(_budgetCtrl.text.replaceAll(',', '.'));
    final minB   = _minBudget();

    if (name.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).bizErrorNameRequired);
      return;
    }
    if (budget == null || budget <= 0) {
      setState(() => _error = AppLocalizations.of(context).bizErrorBudgetInvalid);
      return;
    }
    if (budget < minB) {
      final fmt = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
      setState(() => _error = AppLocalizations.of(context).bizErrorMinBudget(fmt.format(minB)));
      return;
    }
    final balance = widget.state.credit?.balanceMxn ?? 0;
    if (budget > balance) {
      final fmt = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
      setState(() => _error = AppLocalizations.of(context).bizErrorInsufficientBalance(fmt.format(balance)));
      return;
    }
    if (_adType == 'promotion' && _selectedPromoId == null) {
      setState(() => _error = AppLocalizations.of(context).bizErrorSelectPromo);
      return;
    }

    setState(() { _saving = true; _error = null; });
    try {
      await context.read<BusinessAdsCubit>().createCampaign(
        name:         name,
        format:       _effectiveFormat,
        placements:   _effectivePlacements,
        budgetMxn:    budget,
        radiusKm:     _radiusKm,
        geoMode:      _geoMode,
        targetMinAge: _ageRange.start.round(),
        targetMaxAge: _ageRange.end.round(),
        targetGender: _gender,
        promotionId:  _adType == 'promotion' ? _selectedPromoId : null,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() { _saving = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom  = MediaQuery.of(context).viewInsets.bottom;
    final fmt     = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final reach   = _estimatedReach();
    final minB    = _minBudget();

    return Container(
      margin:  const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottom),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.campaign_outlined,
                    size: 20, color: Color(0xFF00838F)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(AppLocalizations.of(context).bizNewCampaign,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                ),
                IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 20),

            // Nombre
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).bizCampaignName,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // ── Tipo de anuncio ─────────────────────────────────────────────
            Text(AppLocalizations.of(context).bizWhatToAdvertise,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _adType = 'establishment';
                      _selectedPromoId = null;
                      _specialFormat = null;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _adType == 'establishment'
                            ? const Color(0xFF00838F).withOpacity(0.12)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _adType == 'establishment'
                              ? const Color(0xFF00838F)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.store_outlined, size: 20,
                              color: _adType == 'establishment'
                                  ? const Color(0xFF00838F) : Colors.grey),
                          const SizedBox(height: 4),
                          Text(AppLocalizations.of(context).bizYourBusiness,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:   12,
                                fontWeight: FontWeight.w600,
                                color: _adType == 'establishment'
                                    ? const Color(0xFF00838F) : Colors.black54,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _adType = 'promotion';
                      _specialFormat = null;
                      // 'banner' no aplica para promos
                      _placements.remove('banner');
                      if (_placements.isEmpty) _placements.add('splash');
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _adType == 'promotion'
                            ? const Color(0xFF00838F).withOpacity(0.12)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _adType == 'promotion'
                              ? const Color(0xFF00838F)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.local_offer_outlined, size: 20,
                              color: _adType == 'promotion'
                                  ? const Color(0xFF00838F) : Colors.grey),
                          const SizedBox(height: 4),
                          Text(AppLocalizations.of(context).bizOnePromotion,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:   12,
                                fontWeight: FontWeight.w600,
                                color: _adType == 'promotion'
                                    ? const Color(0xFF00838F) : Colors.black54,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── ¿Dónde mostrar? (placements) ────────────────────────────────
            if (_specialFormat == null) ...[
              Text(AppLocalizations.of(context).bizWhereToShow,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              ...<(String, IconData, String)>[
                ('splash',        Icons.play_circle_outline,    AppLocalizations.of(context).bizPlacementSplash),
                ('featured_list', Icons.grid_view_outlined,     AppLocalizations.of(context).bizPlacementFeed),
                if (_adType == 'establishment')
                  ('banner',      Icons.view_headline_outlined, AppLocalizations.of(context).bizPlacementBanner),
              ].map(((String, IconData, String) p) {
                final sel = _placements.contains(p.$1);
                return InkWell(
                  onTap: () => setState(() {
                    if (sel) {
                      if (_placements.length > 1) _placements.remove(p.$1);
                    } else {
                      _placements.add(p.$1);
                    }
                  }),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Icon(
                          sel ? Icons.check_box : Icons.check_box_outline_blank,
                          size:  20,
                          color: sel ? const Color(0xFF00838F) : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Icon(p.$2, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(p.$3,
                            style: TextStyle(
                              fontSize: 13,
                              color: sel ? const Color(0xFF00838F) : Colors.black87,
                            )),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],

            // ── Formatos especiales (solo establecimiento) ───────────────────
            if (_adType == 'establishment') ...[
              Text(AppLocalizations.of(context).bizSpecialFormats,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize:   12,
                    color:      Colors.grey.shade600,
                  )),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8, runSpacing: 6,
                children: [
                  ChoiceChip(
                    label:    Text(AppLocalizations.of(context).bizFormatPush),
                    selected: _specialFormat == 'push',
                    onSelected: (v) => setState(() =>
                        _specialFormat = v ? 'push' : null),
                    selectedColor: const Color(0xFF00838F).withOpacity(0.15),
                    labelStyle: TextStyle(
                        color: _specialFormat == 'push'
                            ? const Color(0xFF00838F) : Colors.black87,
                        fontSize: 12),
                  ),
                  ChoiceChip(
                    label:    Text(AppLocalizations.of(context).bizFormatFlash),
                    selected: _specialFormat == 'flash',
                    onSelected: (v) => setState(() =>
                        _specialFormat = v ? 'flash' : null),
                    selectedColor: const Color(0xFF00838F).withOpacity(0.15),
                    labelStyle: TextStyle(
                        color: _specialFormat == 'flash'
                            ? const Color(0xFF00838F) : Colors.black87,
                        fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Presupuesto
            TextField(
              controller:   _budgetCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged:    (_) => setState(() {}),
              decoration: InputDecoration(
                labelText:  AppLocalizations.of(context).bizBudgetMxn,
                prefixText: '\$ ',
                helperText: minB > 0 ? AppLocalizations.of(context).bizMinimum(fmt.format(minB)) : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            if (reach > 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.people_outline,
                      size: 14, color: Color(0xFF00838F)),
                  const SizedBox(width: 4),
                  Text(AppLocalizations.of(context).bizEstimatedReach(reach),
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF00838F))),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Radio
            Row(
              children: [
                Text(AppLocalizations.of(context).bizRadius,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(width: 8),
                Text('$_radiusKm km',
                    style: const TextStyle(
                        color: Color(0xFF00838F), fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value:      _radiusKm.toDouble(),
              min:        1,
              max:        50,
              divisions:  49,
              activeColor: const Color(0xFF00838F),
              label:      '$_radiusKm km',
              onChanged:  (v) => setState(() => _radiusKm = v.round()),
            ),
            const SizedBox(height: 8),

            // Geo mode
            Text(AppLocalizations.of(context).bizGeoSegmentation,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 4),
            ..._geoModeKeys.map((String m) => RadioListTile<String>(
                  title:        Text(_geoModeLabel(context, m), style: const TextStyle(fontSize: 13)),
                  value:        m,
                  groupValue:   _geoMode,
                  activeColor:  const Color(0xFF00838F),
                  dense:        true,
                  contentPadding: EdgeInsets.zero,
                  onChanged:    (v) => setState(() => _geoMode = v!),
                )),

            const SizedBox(height: 16),

            // ── Rango de edad ──────────────────────────────────────────────
            Row(
              children: [
                Text(AppLocalizations.of(context).bizAge,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                Text(
                  AppLocalizations.of(context).bizAgeRange(
                      _ageRange.start.round(), _ageRange.end.round()),
                  style: const TextStyle(
                      color: Color(0xFF00838F), fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ],
            ),
            RangeSlider(
              values:      _ageRange,
              min:         18,
              max:         80,
              divisions:   62,
              activeColor: const Color(0xFF00838F),
              labels:      RangeLabels(
                AppLocalizations.of(context).bizYearsOld(_ageRange.start.round()),
                AppLocalizations.of(context).bizYearsOld(_ageRange.end.round()),
              ),
              onChanged: (v) {
                setState(() => _ageRange = v);
                _refreshReach();
              },
            ),
            const SizedBox(height: 4),

            // ── Sexo ───────────────────────────────────────────────────────
            Text(AppLocalizations.of(context).bizGender,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: <(String, String)>[
                ('all',    AppLocalizations.of(context).bizGenderAll),
                ('male',   AppLocalizations.of(context).bizGenderMale),
                ('female', AppLocalizations.of(context).bizGenderFemale),
              ].map(((String, String) g) {
                final sel = _gender == g.$1;
                return ChoiceChip(
                  label:         Text(g.$2),
                  selected:      sel,
                  onSelected:    (_) {
                    setState(() => _gender = g.$1);
                    _refreshReach();
                  },
                  selectedColor: const Color(0xFF00838F).withOpacity(0.15),
                  labelStyle:    TextStyle(
                      color:     sel ? const Color(0xFF00838F) : Colors.black87,
                      fontSize:  12),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // ── Audiencia potencial (live) ─────────────────────────────────
            Container(
              padding:     const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration:  BoxDecoration(
                color:        const Color(0xFF00838F).withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
                border:       Border.all(
                    color: const Color(0xFF00838F).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_outline,
                      size: 18, color: Color(0xFF00838F)),
                  const SizedBox(width: 10),
                  if (_fetchingReach)
                    const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: Color(0xFF00838F)),
                    )
                  else
                    Expanded(
                      child: Text(
                        _reachPool != null
                            ? AppLocalizations.of(context).bizAudienceWithFilters(
                                NumberFormat.compact(locale: "es_MX").format(_reachPool!))
                            : AppLocalizations.of(context).bizCalculatingAudience,
                        style: const TextStyle(
                          fontSize:   13,
                          color:      Color(0xFF00838F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Promoción a publicitar (solo cuando _adType == 'promotion') ──
            if (_adType == 'promotion') ...[
              Text(AppLocalizations.of(context).bizPromoToAdvertise,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              if (widget.promotions.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color:        Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border:       Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).bizCreatePromoFirst,
                          style: const TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...widget.promotions.map((p) => _PromoPickerRow(
                  promo:    p,
                  selected: _selectedPromoId == p.id,
                  onTap:    () => setState(() => _selectedPromoId = p.id),
                )),
              const SizedBox(height: 8),
            ],

            // Error
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:        Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border:       Border.all(color: Colors.red.shade200),
                ),
                child: Text(_error!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
              ),
            ],
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    child: Text(AppLocalizations.of(context).bizCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00838F),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(AppLocalizations.of(context).bizLaunchCampaign),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VISTA GERENTE — mostrada cuando el usuario tiene profiles.role = 'staff'
// ═══════════════════════════════════════════════════════════════════════════════

/// Datos de un establecimiento gestionado por el empleado.
class _StaffEstData {
  final String id;
  final String name;
  final String role;
  final Map<String, dynamic> permissions;
  final List<PromotionModel> promos;

  const _StaffEstData({
    required this.id,
    required this.name,
    required this.role,
    required this.permissions,
    required this.promos,
  });

  bool get canManagePromos   => permissions['manage_promos']   == true;
  bool get canViewStats      => permissions['view_stats']      == true;
  bool get canScanQr         => permissions['scan_qr']         == true;
  bool get canManagePayments => permissions['manage_payments'] == true;
}

/// Pantalla principal para usuarios con role='staff'.
class _StaffBusinessView extends StatefulWidget {
  const _StaffBusinessView();

  @override
  State<_StaffBusinessView> createState() => _StaffBusinessViewState();
}

class _StaffBusinessViewState extends State<_StaffBusinessView> {
  final _staffRepo = StaffRepository();
  final _bizRepo   = BusinessRepository();

  bool _loading = true;
  List<_StaffEstData> _estList = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _openPromoForm(BuildContext ctx, {
    PromotionModel?  promo,
    required _StaffEstData est,
  }) {
    final auth   = context.read<AuthBloc>().state;
    final userId = auth is AuthAuthenticated ? auth.user.id : '';
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => PromoFormScreen(
          existing:          promo,
          establishmentName: est.name,
          establishmentId:   est.id,
          staffUserId:       userId,
        ),
      ),
    ).then((_) => _load()); // recarga promos al volver
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final memberships = await _staffRepo.getMyStaffMemberships();
      debugPrint('[StaffView] memberships=${memberships.length}');
      final list = <_StaffEstData>[];
      for (final m in memberships) {
        // establishments siempre tiene al menos {id, name} gracias al fallback
        final estRaw  = m['establishments'] as Map<String, dynamic>?;
        final estId   = (estRaw?['id']   as String?)
                     ?? (m['establishment_id'] as String?) ?? '';
        final estName = (estRaw?['name'] as String?) ?? '—';
        if (estId.isEmpty) continue;

        final role  = m['role']        as String? ?? '';
        final perms = Map<String, dynamic>.from(
            (m['permissions'] as Map?) ?? {});
        List<PromotionModel> promos = [];
        try {
          promos = await _bizRepo.getOwnerPromosByEstablishment(
            establishmentId:   estId,
            establishmentName: estName,
          );
        } catch (e) {
          debugPrint('[StaffView] promos error: $e');
        }
        list.add(_StaffEstData(
          id:          estId,
          name:        estName,
          role:        role,
          permissions: perms,
          promos:      promos,
        ));
      }
      debugPrint('[StaffView] list built: ${list.length} establishments');
      if (mounted) setState(() { _estList = list; _loading = false; });
    } catch (e) {
      debugPrint('[StaffView] _load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(AppLocalizations.of(context).bizMyBusiness,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_estList.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(AppLocalizations.of(context).bizMyBusiness,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.store_outlined,
                    size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).bizNoAssignedEstablishments,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).bizAskOwnerToInvite,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(AppLocalizations.of(context).bizMyBusiness,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: AppLocalizations.of(context).bizRefresh,
            onPressed: _load,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _estList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (ctx, i) => _StaffEstCard(
            est:          _estList[i],
            onOpenForm:   (promo) => _openPromoForm(ctx, promo: promo, est: _estList[i]),
            onNewPromo:   () => _openPromoForm(ctx, est: _estList[i]),
            onReload:     _load,
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de un establecimiento en la vista del gerente.
class _StaffEstCard extends StatelessWidget {
  final _StaffEstData                est;
  final void Function(PromotionModel) onOpenForm;
  final VoidCallback                  onNewPromo;
  final VoidCallback                  onReload;

  const _StaffEstCard({
    required this.est,
    required this.onOpenForm,
    required this.onNewPromo,
    required this.onReload,
  });

  String _roleLabel(BuildContext context, String role) {
    final l = AppLocalizations.of(context);
    switch (role) {
      case 'manager': return l.bizRoleManager;
      case 'cashier': return l.bizRoleCashier;
      default:        return l.bizRoleCustom;
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'manager': return const Color(0xFF3949AB);
      case 'cashier': return const Color(0xFF00897B);
      default:        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(est.role);

    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow:    [
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
          // ── Cabecera ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color:        color.withAlpha(15),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.store_outlined, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        est.name,
                        style: const TextStyle(
                          fontSize:   15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:        color.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _roleLabel(context, est.role),
                          style: TextStyle(
                            fontSize:   11,
                            fontWeight: FontWeight.w600,
                            color:      color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Permisos (chips indicadores) ──────────────────────────────────
          if (est.canManagePromos || est.canViewStats ||
              est.canScanQr       || est.canManagePayments)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (est.canManagePromos)
                    _PermChip(
                      icon:  Icons.campaign_outlined,
                      label: AppLocalizations.of(context).bizPermManagePromosShort,
                      color: color,
                    ),
                  if (est.canViewStats)
                    _PermChip(
                      icon:  Icons.bar_chart_outlined,
                      label: AppLocalizations.of(context).bizPermViewStats,
                      color: color,
                    ),
                  if (est.canScanQr)
                    _PermChip(
                      icon:  Icons.qr_code_scanner_outlined,
                      label: AppLocalizations.of(context).bizScanStamps,
                      color: color,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => LoyaltyCubit(
                              repository:        LoyaltyRepository(),
                              establishmentId:   est.id,
                              establishmentName: est.name,
                            )..load(),
                            child: const QrScannerScreen(),
                          ),
                        ),
                      ),
                    ),
                  if (est.canManagePayments)
                    _PermChip(
                      icon:  Icons.payments_outlined,
                      label: AppLocalizations.of(context).bizAdvertising,
                      color: const Color(0xFF2E7D32),
                    ),
                ],
              ),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child:   Divider(height: 24),
          ),

          // ── Sección de promociones (igual que la vista del dueño) ─────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _PromosSection(
              promos:             est.promos,
              promosLoaded:       true,
              maxPromos:          null,
              totalUsed:          est.promos.length,
              canAdd:             est.canManagePromos,
              onAdd:              onNewPromo,
              onEdit:             onOpenForm,
              showFeaturedToggle: est.canManagePromos,
              onToggleFeatured:   est.canManagePromos
                  ? (id) => BusinessRepository()
                      .toggleFeatured(id)
                      .then((_) => onReload())
                      .catchError((_) {})
                  : null,
            ),
          ),

          // ── Estadísticas ───────────────────────────────────────────────────
          if (est.canViewStats) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: StatsSection(establishmentId: est.id),
            ),
          ],

          // ── Publicidad ─────────────────────────────────────────────────────
          if (est.canManagePayments) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _AdsSection(establishmentId: est.id),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Chip de permiso — opcionalmente tappable.
class _PermChip extends StatelessWidget {
  final IconData  icon;
  final String    label;
  final Color     color;
  final VoidCallback? onTap;
  const _PermChip({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        color.withAlpha(12),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize:   11,
              fontWeight: FontWeight.w500,
              color:      color,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 3),
            Icon(Icons.arrow_forward_ios_rounded, size: 9, color: color),
          ],
        ],
      ),
    );
    if (onTap == null) return chip;
    return GestureDetector(onTap: onTap, child: chip);
  }
}

/// Tile de promoción en la vista del gerente — toca para ver detalle.
class _StaffPromoTile extends StatelessWidget {
  final PromotionModel promo;
  final bool           canEdit;
  final VoidCallback?  onEdit;
  const _StaffPromoTile({
    required this.promo,
    this.canEdit = false,
    this.onEdit,
  });

  String _typeLabel(BuildContext context, String type) {
    final l = AppLocalizations.of(context);
    switch (type) {
      case 'flash':     return l.bizPromoTypeFlash;
      case 'daily':     return l.bizPromoTypeDaily;
      case 'weekly':    return l.bizPromoTypeWeekly;
      case 'permanent': return l.bizPromoTypePermanent;
      default:          return type;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'flash':  return Icons.bolt_outlined;
      case 'daily':  return Icons.today_outlined;
      default:       return Icons.local_offer_outlined;
    }
  }

  void _openDetail(BuildContext context) {
    final auth    = context.read<AuthBloc>().state;
    final userId  = auth is AuthAuthenticated ? auth.user.id : null;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PromoDetailScreen(promo: promo, userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = promo.isCurrentlyActive;
    final color  = active ? AppColors.primary : Colors.grey.shade400;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Material(
        color:        Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _openDetail(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color:        active
                  ? AppColors.primary.withAlpha(8)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border:       Border.all(
                color: active
                    ? AppColors.primary.withAlpha(40)
                    : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(_typeIcon(promo.type), size: 18, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo.name,
                        style: TextStyle(
                          fontSize:   13,
                          fontWeight: FontWeight.w600,
                          color:      active
                              ? Colors.black87
                              : Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _typeLabel(context, promo.type),
                        style: TextStyle(fontSize: 11, color: color),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color:        active
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border:       Border.all(
                      color: active
                          ? Colors.green.shade200
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    active ? AppLocalizations.of(context).bizActive : AppLocalizations.of(context).bizInactive,
                    style: TextStyle(
                      fontSize:   10,
                      fontWeight: FontWeight.w600,
                      color:      active
                          ? Colors.green.shade700
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
                if (canEdit) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color:  AppColors.primary.withAlpha(15),
                        shape:  BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_outlined,
                          size: 13, color: AppColors.primary),
                    ),
                  ),
                ] else if (promo.isLocked) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.lock_outline,
                      size: 14, color: Colors.orange.shade300),
                ],
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Phase D: Bottom sheet de recarga MercadoPago ────────────────────────────

class _TopUpSheet extends StatefulWidget {
  final String establishmentId;
  const _TopUpSheet({required this.establishmentId});

  @override
  State<_TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<_TopUpSheet> {
  static const _presets = [100.0, 200.0, 500.0, 1000.0];
  static const _adColor = Color(0xFF00838F);

  double?  _selected;           // null = custom
  final _customCtrl = TextEditingController();
  bool  _loading    = false;
  String? _error;

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  double? get _amount {
    if (_selected != null) return _selected;
    return double.tryParse(_customCtrl.text.replaceAll(',', '.'));
  }

  Future<void> _pay() async {
    final amount = _amount;
    if (amount == null || amount < 50) {
      setState(() => _error = AppLocalizations.of(context).bizMinAmount50);
      return;
    }
    final cannotOpenMsg = AppLocalizations.of(context).bizCannotOpenMercadoPago;
    setState(() { _loading = true; _error = null; });
    try {
      final repo = AdsRepository();
      final initPoint = await repo.createMpPreference(
        establishmentId: widget.establishmentId,
        amountMxn:       amount,
      );
      final uri = Uri.parse(initPoint);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception(cannotOpenMsg);
      }
      if (!mounted) return;
      // Capturar referencias ANTES del pop (el contexto se desmonta al hacer pop)
      final messenger = ScaffoldMessenger.of(context);
      final adsCubit  = context.read<BusinessAdsCubit>();
      final redirectMsg = AppLocalizations.of(context).bizRedirectedToMercadoPago;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(redirectMsg),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ),
      );
      // Recargar el estado publicitario para reflejar cualquier cambio de saldo
      adsCubit.load();
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final fmt    = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Container(
      margin:  const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottom),
      decoration: const BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Título ─────────────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 20, color: _adColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(AppLocalizations.of(context).bizTopUpAdCredit,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                ),
                IconButton(
                  icon:      const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).bizTopUpDesc,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 20),

            // ── Montos predefinidos ─────────────────────────────────────────
            Text(AppLocalizations.of(context).bizAmountToTopUp,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: Color(0xFF9E9E9E), letterSpacing: 0.6)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _presets.map((p) {
                final sel = _selected == p;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selected = p;
                    _customCtrl.clear();
                    _error = null;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color:  sel
                          ? _adColor.withAlpha(20)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? _adColor : Colors.grey.shade200,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      fmt.format(p),
                      style: TextStyle(
                        fontSize:   15,
                        fontWeight: FontWeight.w600,
                        color: sel ? _adColor : AppColors.textDark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ── Monto personalizado ─────────────────────────────────────────
            TextField(
              controller:   _customCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged:    (v) => setState(() {
                _selected = null;
                _error    = null;
              }),
              decoration: InputDecoration(
                labelText:   AppLocalizations.of(context).bizOtherAmount,
                prefixText:  '\$ ',
                suffixText:  'MXN',
                helperText:  AppLocalizations.of(context).bizMin50Mxn,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

            // ── Error ───────────────────────────────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:        Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border:       Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        size: 16, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: TextStyle(
                              fontSize: 12, color: Colors.red.shade700)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ── Resumen del pago ────────────────────────────────────────────
            if (_amount != null && _amount! >= 50)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:        _adColor.withAlpha(10),
                  borderRadius: BorderRadius.circular(10),
                  border:       Border.all(color: _adColor.withAlpha(40)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: _adColor),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).bizTotalToPay(fmt.format(_amount!)),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _adColor),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ── Botón MP ────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _pay,
                icon: _loading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.open_in_new, size: 18),
                label: Text(
                  _loading
                      ? AppLocalizations.of(context).bizPreparingPayment
                      : AppLocalizations.of(context).bizPayWithMercadoPago,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009EE3), // color oficial MP
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Center(
              child: Text(
                AppLocalizations.of(context).bizWillRedirectMercadoPago,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
