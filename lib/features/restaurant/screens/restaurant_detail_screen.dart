import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:promofy/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/establishment_badges_row.dart';
import '../../../core/widgets/report_sheet.dart';
import '../../../data/models/establishment_model.dart';
import '../../../data/models/loyalty_program_model.dart';
import '../../../data/models/promotion_model.dart';
import '../cubit/restaurant_detail_cubit.dart';
import '../cubit/restaurant_detail_state.dart';

const String _kMapsApiKey = 'AIzaSyB1Sp1SZlxiJ-yjlfLL1CmiwN-iFSyUscY';

class RestaurantDetailScreen extends StatelessWidget {
  final String establishmentName;

  const RestaurantDetailScreen({
    super.key,
    required this.establishmentName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantDetailCubit, RestaurantDetailState>(
      builder: (context, state) {
        if (state is RestaurantDetailLoading ||
            state is RestaurantDetailInitial) {
          return _LoadingScaffold(name: establishmentName);
        }
        if (state is RestaurantDetailError) {
          return _ErrorScaffold(message: state.message);
        }
        if (state is RestaurantDetailLoaded) {
          return _LoadedView(
            establishment:     state.establishment,
            promos:            state.promos,
            loyaltyProgram:    state.loyaltyProgram,
            onFavoriteToggled: (promo) =>
                context.read<RestaurantDetailCubit>().toggleFavorite(promo),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Vista principal ──────────────────────────────────────────────────────────

class _LoadedView extends StatelessWidget {
  final EstablishmentModel             establishment;
  final List<PromotionModel>           promos;
  final LoyaltyProgramModel?           loyaltyProgram;
  final void Function(PromotionModel)? onFavoriteToggled;

  const _LoadedView({
    required this.establishment,
    required this.promos,
    this.loyaltyProgram,
    this.onFavoriteToggled,
  });

  @override
  Widget build(BuildContext context) {
    final hasLogo = establishment.logoUrl != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [

          // ── SliverAppBar ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned:          true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              // Compartir establecimiento (link a su página pública)
              IconButton(
                icon: const Icon(Icons.ios_share, color: Colors.white),
                tooltip: 'Compartir',
                onPressed: () => Share.share(
                  '¡Mira ${establishment.name} en Promofy! 📲 '
                  'La app donde decides a dónde ir.\n'
                  'https://promofy.fun/e/${establishment.id}',
                  subject: establishment.name,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (v) {
                  if (v == 'report') {
                    showReportSheet(
                      context,
                      contentType: 'establishment',
                      contentId:   establishment.id,
                    );
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined, size: 18, color: Colors.black54),
                        SizedBox(width: 10),
                        Text('Reportar'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                // Al colapsar el header, fijamos el nombre arriba para no perder
                // de vista qué establecimiento se está viendo.
                final collapsed = constraints.biggest.height <=
                    MediaQuery.of(context).padding.top + kToolbarHeight + 8;
                return FlexibleSpaceBar(
                  title: collapsed
                      ? Text(
                          establishment.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color:      Colors.white,
                            fontSize:   16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                  titlePadding: const EdgeInsetsDirectional.only(
                      start: 54, end: 96, bottom: 16),
                  background: Stack(
                fit: StackFit.expand,
                children: [
                  if (establishment.photoUrls.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl:    establishment.photoUrls.first,
                      fit:         BoxFit.cover,
                      placeholder: (_, __) => const _GradientBg(),
                      errorWidget: (_, __, ___) => const _GradientBg(),
                    )
                  else if (hasLogo)
                    CachedNetworkImage(
                      imageUrl:    establishment.logoUrl!,
                      fit:         BoxFit.cover,
                      placeholder: (_, __) => const _GradientBg(),
                      errorWidget: (_, __, ___) => const _GradientBg(),
                    )
                  else
                    const _GradientBg(),

                  // Gradiente inferior
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin:  Alignment.topCenter,
                        end:    Alignment.bottomCenter,
                        stops:  const [0.35, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(178),
                        ],
                      ),
                    ),
                  ),

                  // Logo circular
                  if (hasLogo)
                    Positioned(
                      left:   14,
                      bottom: 12,
                      child: Container(
                        width:  52,
                        height: 52,
                        decoration: BoxDecoration(
                          color:  Colors.white,
                          shape:  BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color:      Colors.black.withAlpha(60),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl:    establishment.logoUrl!,
                            fit:         BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.primary.withAlpha(20),
                              child: const Icon(Icons.store,
                                  color: AppColors.primary, size: 24),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Nombre + categoría
                  Positioned(
                    left:   hasLogo ? 78 : 14,
                    right:  14,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize:       MainAxisSize.min,
                      children: [
                        Text(
                          establishment.name,
                          style: const TextStyle(
                            color:      Colors.white,
                            fontSize:   18,
                            fontWeight: FontWeight.w600,
                            shadows:    [
                              Shadow(blurRadius: 4,
                                  color: Colors.black38),
                            ],
                          ),
                        ),
                        if (establishment.address != null &&
                            establishment.address!.isNotEmpty)
                          Text(
                            establishment.address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color:    Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Rating badge
                  Positioned(
                    bottom: 12,
                    right:  12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color:        Colors.black.withAlpha(153),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFF59E0B), size: 14),
                          const SizedBox(width: 3),
                          Text(
                            establishment.displayRating
                                .toStringAsFixed(1),
                            style: const TextStyle(
                              color:      Colors.white,
                              fontSize:   13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!establishment.hasRealRating)
                            Text(' · ${AppLocalizations.of(context).restaurantNew}',
                                style: const TextStyle(
                                    color:    Colors.white70,
                                    fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
                  ),
                );
              },
            ),
          ),

          // ── Insignias de la zona ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: EstablishmentBadgesRow(establishmentId: establishment.id),
          ),

          // ── Sección: info + contacto ──────────────────────────────────────
          SliverToBoxAdapter(
            child: _InfoSection(establishment: establishment),
          ),

          // ── Sección: características + pagos ─────────────────────────────
          if (establishment.characteristics.isNotEmpty ||
              establishment.paymentMethods.isNotEmpty)
            SliverToBoxAdapter(
              child: _CharsAndPaymentsSection(
                characteristics: establishment.characteristics,
                paymentMethods:  establishment.paymentMethods,
              ),
            ),

          // ── Sección: horario ──────────────────────────────────────────────
          if (establishment.schedule != null &&
              establishment.schedule!.isNotEmpty)
            SliverToBoxAdapter(
              child: _ScheduleSection(schedule: establishment.schedule!),
            ),

          // ── Sección: mapa estático ────────────────────────────────────────
          if (establishment.lat != null && establishment.lng != null)
            SliverToBoxAdapter(
              child: _MapSection(
                lat:     establishment.lat!,
                lng:     establishment.lng!,
                address: establishment.address,
                mapsUrl: establishment.googleMapsUrl,
              ),
            ),

          // ── Sección: galería ──────────────────────────────────────────────
          if (establishment.photoUrls.isNotEmpty)
            SliverToBoxAdapter(
              child: _PhotoGallerySection(
                  photoUrls: establishment.photoUrls),
            ),

          // ── Sección: programa de lealtad ──────────────────────────────────
          if (loyaltyProgram != null)
            SliverToBoxAdapter(
              child: _LoyaltyBanner(program: loyaltyProgram!),
            ),

          // ── Sección: promos ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _PromosSection(
              promos:            promos,
              onFavoriteToggled: onFavoriteToggled,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ─── Info + contacto ──────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  final EstablishmentModel establishment;
  const _InfoSection({required this.establishment});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasWhatsApp  = establishment.whatsAppUrl   != null;
    final hasPhone     = establishment.phone != null &&
                         establishment.phone!.isNotEmpty;
    final hasMaps      = establishment.googleMapsUrl != null;
    final hasWebsite   = establishment.website != null &&
                         establishment.website!.isNotEmpty;
    final hasFacebook  = establishment.facebookUrl != null &&
                         establishment.facebookUrl!.isNotEmpty;
    final hasInstagram = establishment.instagramUrl != null &&
                         establishment.instagramUrl!.isNotEmpty;
    final hasAny = hasWhatsApp || hasPhone || hasMaps ||
                   hasWebsite  || hasFacebook || hasInstagram;

    return Container(
      color:   Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chips + calificación + corazón (misma fila)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Wrap(
                  spacing:    8,
                  runSpacing: 6,
                  children: [
                    if (establishment.distanceFormatted.isNotEmpty)
                      _Chip(
                        icon:  Icons.location_on_outlined,
                        label: establishment.distanceFormatted,
                      ),
                    if (establishment.establishmentType != null)
                      _Chip(
                        icon:  establishment.establishmentType == 'urban_mobile'
                            ? Icons.directions_car_outlined
                            : Icons.storefront_outlined,
                        label: establishment.establishmentType == 'urban_mobile'
                            ? AppLocalizations.of(context).restaurantTypeUrbanMobile
                            : AppLocalizations.of(context).restaurantTypeLocal,
                        color: AppColors.secondary,
                      ),
                    if (establishment.adultPromotions)
                      _Chip(
                        icon:  Icons.no_adult_content,
                        label: '+18',
                        color: Colors.orange.shade700,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Calificación
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 3),
                  Text(
                    establishment.displayRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize:   12,
                      fontWeight: FontWeight.w600,
                      color:      AppColors.textDark,
                    ),
                  ),
                  if (!establishment.hasRealRating)
                    Text(
                      ' · ${AppLocalizations.of(context).restaurantNew}',
                      style: TextStyle(
                          fontSize: 10,
                          color:    Colors.grey.shade500),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Favorito establecimiento + conteo
              GestureDetector(
                onTap: () => context
                    .read<RestaurantDetailCubit>()
                    .toggleEstablishmentFavorite(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      establishment.isFavorited
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size:  22,
                      color: establishment.isFavorited
                          ? Colors.red.shade400
                          : Colors.grey.shade400,
                    ),
                    if (establishment.favoritesCount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '${establishment.favoritesCount}',
                        style: TextStyle(
                          fontSize:   12,
                          fontWeight: FontWeight.w600,
                          color:      establishment.isFavorited
                              ? Colors.red.shade400
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Descripción
          if (establishment.description != null &&
              establishment.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              establishment.description!,
              style: TextStyle(
                fontSize: 13,
                color:    AppColors.textDark.withAlpha(180),
                height:   1.45,
              ),
            ),
          ],

          // Botones de contacto
          if (hasAny) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing:    8,
              runSpacing: 8,
              children: [
                if (hasWhatsApp)
                  _ContactBtn(
                    icon:  Icons.chat_rounded,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () {
                      context.read<RestaurantDetailCubit>()
                          .logContactClick('whatsapp');
                      _launch(establishment.whatsAppUrl!);
                    },
                  ),
                if (hasPhone && !hasWhatsApp)
                  _ContactBtn(
                    icon:  Icons.phone_outlined,
                    label: AppLocalizations.of(context).restaurantCall,
                    color: AppColors.primary,
                    onTap: () {
                      context.read<RestaurantDetailCubit>()
                          .logContactClick('phone');
                      _launch('tel:${establishment.phone}');
                    },
                  ),
                if (hasFacebook)
                  _ContactBtnFa(
                    faIcon: FontAwesomeIcons.facebook,
                    label:  'Facebook',
                    color:  const Color(0xFF1877F2),
                    onTap:  () {
                      context.read<RestaurantDetailCubit>()
                          .logContactClick('facebook');
                      _launch(establishment.facebookUrl!);
                    },
                  ),
                if (hasInstagram)
                  _ContactBtnFa(
                    faIcon: FontAwesomeIcons.instagram,
                    label:  'Instagram',
                    color:  const Color(0xFFE1306C),
                    onTap:  () {
                      context.read<RestaurantDetailCubit>()
                          .logContactClick('instagram');
                      _launch(establishment.instagramUrl!);
                    },
                  ),
                if (hasWebsite)
                  _ContactBtn(
                    icon:  Icons.language_outlined,
                    label: AppLocalizations.of(context).restaurantWebsite,
                    color: Colors.grey.shade600,
                    onTap: () {
                      context.read<RestaurantDetailCubit>()
                          .logContactClick('website');
                      _launch(establishment.website!);
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Características + Métodos de pago (2 columnas) ───────────────────────────

class _CharsAndPaymentsSection extends StatelessWidget {
  final List<dynamic> characteristics;
  final List<String>  paymentMethods;

  const _CharsAndPaymentsSection({
    required this.characteristics,
    required this.paymentMethods,
  });

  static const _paymentLabels = {
    'card':  'Tarjeta',
    'cash':  'Efectivo',
    'other': 'Otro',
  };
  static const _paymentIcons = {
    'card':  Icons.credit_card_outlined,
    'cash':  Icons.payments_outlined,
    'other': Icons.more_horiz,
  };

  @override
  Widget build(BuildContext context) {
    final showChars    = characteristics.isNotEmpty;
    final showPayments = paymentMethods.isNotEmpty;

    return Container(
      margin:     const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna izquierda: Características (2 sub-columnas, todas visibles)
            if (showChars)
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).restaurantCharacteristics,
                        style: TextStyle(
                          fontSize:   10,
                          fontWeight: FontWeight.w600,
                          color:      Colors.grey.shade500,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 7),
                      ...List.generate(
                        ((characteristics.length + 1) ~/ 2),
                        (row) {
                          final i1 = row * 2;
                          final i2 = row * 2 + 1;
                          Widget charItem(dynamic c) => Row(
                            children: [
                              Text(c.icon ?? '✓',
                                  style: const TextStyle(fontSize: 11)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  c.localizedName(Localizations.localeOf(context).languageCode) as String,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textDark),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Row(
                              children: [
                                Expanded(child: charItem(characteristics[i1])),
                                if (i2 < characteristics.length)
                                  Expanded(child: charItem(characteristics[i2])),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

            // Divider vertical
            if (showChars && showPayments)
              VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Colors.grey.shade100),

            // Columna derecha: Métodos de pago (más angosta)
            if (showPayments)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).restaurantPaymentMethods,
                        style: TextStyle(
                          fontSize:   10,
                          fontWeight: FontWeight.w600,
                          color:      Colors.grey.shade500,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 7),
                      ...paymentMethods.map((key) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              children: [
                                Icon(
                                  _paymentIcons[key] ??
                                      Icons.payment_outlined,
                                  size:  13,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _paymentLabels[key] ?? key,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textDark),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Horario ──────────────────────────────────────────────────────────────────

class _ScheduleSection extends StatelessWidget {
  final Map<String, dynamic> schedule;
  const _ScheduleSection({required this.schedule});

  static const _dayOrder = [
    'monday','tuesday','wednesday','thursday','friday','saturday','sunday',
  ];
  static const _dayLabels = {
    'monday':    'Lunes',
    'tuesday':   'Martes',
    'wednesday': 'Miércoles',
    'thursday':  'Jueves',
    'friday':    'Viernes',
    'saturday':  'Sábado',
    'sunday':    'Domingo',
  };

  String get _todayKey {
    const keys = ['','monday','tuesday','wednesday',
                   'thursday','friday','saturday','sunday'];
    final wd = DateTime.now().weekday;
    return wd < keys.length ? keys[wd] : '';
  }

  @override
  Widget build(BuildContext context) {
    final days = _dayOrder.where((d) => schedule.containsKey(d)).toList();
    if (days.isEmpty) return const SizedBox.shrink();
    final today = _todayKey;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      color:  Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).restaurantSchedule,
            style: TextStyle(
              fontSize:   10,
              fontWeight: FontWeight.w600,
              color:      Colors.grey.shade500,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            physics:     const NeverScrollableScrollPhysics(),
            shrinkWrap:  true,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:  2,
              mainAxisExtent:  20,
              crossAxisSpacing: 12,
            ),
            itemCount: days.length,
            itemBuilder: (_, i) {
              final day    = days[i];
              final data   = schedule[day];
              final closed = data is Map && data['closed'] == true;
              final open   = data is Map ? (data['open']  as String? ?? '') : '';
              final close  = data is Map ? (data['close'] as String? ?? '') : '';
              final isToday = day == today;

              return Row(
                children: [
                  Expanded(
                    child: Text(
                      _dayLabels[day] ?? day,
                      style: TextStyle(
                        fontSize:   10,
                        color: isToday
                            ? AppColors.primary
                            : Colors.grey.shade600,
                        fontWeight: isToday
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    closed ? AppLocalizations.of(context).restaurantClosed : '$open–$close',
                    style: TextStyle(
                      fontSize:   10,
                      color: isToday
                          ? AppColors.textDark
                          : AppColors.textDark.withAlpha(180),
                      fontWeight: isToday
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Mapa + dirección ─────────────────────────────────────────────────────────

class _MapSection extends StatelessWidget {
  final double  lat;
  final double  lng;
  final String? address;
  final String? mapsUrl;

  const _MapSection({
    required this.lat,
    required this.lng,
    this.address,
    this.mapsUrl,
  });

  String get _staticMapUrl =>
      'https://maps.googleapis.com/maps/api/staticmap'
      '?center=$lat,$lng'
      '&zoom=15'
      '&size=600x160'
      '&scale=2'
      '&markers=color:red%7C$lat,$lng'
      '&key=$_kMapsApiKey';

  Future<void> _openMaps() async {
    if (mapsUrl == null) return;
    final uri = Uri.parse(mapsUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(top: 8),
      color:   Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).restaurantLocation,
            style: TextStyle(
              fontSize:   10,
              fontWeight: FontWeight.w600,
              color:      Colors.grey.shade500,
              letterSpacing: 0.4,
            ),
          ),
          if (address != null && address!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              address!,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textDark),
            ),
          ],
          const SizedBox(height: 8),
          GestureDetector(
            onTap: mapsUrl != null ? _openMaps : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl:    _staticMapUrl,
                    height:      110,
                    width:       double.infinity,
                    fit:         BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 110,
                      color:  Colors.grey.shade100,
                      child:  const Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 110,
                      color:  Colors.grey.shade100,
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_outlined,
                              size:  20,
                              color: Colors.grey.shade400),
                          const SizedBox(width: 6),
                          Text(AppLocalizations.of(context).restaurantViewOnMap,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  ),
                  if (mapsUrl != null)
                    Positioned(
                      bottom: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color:        Colors.white.withAlpha(230),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:      Colors.black.withAlpha(25),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions,
                                size: 12,
                                color: Color(0xFF4285F4)),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context).restaurantGetDirections,
                              style: const TextStyle(
                                fontSize:   11,
                                fontWeight: FontWeight.w600,
                                color:      Color(0xFF4285F4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Galería horizontal ───────────────────────────────────────────────────────

class _PhotoGallerySection extends StatelessWidget {
  final List<String> photoUrls;
  const _PhotoGallerySection({required this.photoUrls});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color:  Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Text(
              AppLocalizations.of(context).restaurantPhotos,
              style: TextStyle(
                fontSize:   10,
                fontWeight: FontWeight.w600,
                color:      Colors.grey.shade500,
                letterSpacing: 0.4,
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection:  Axis.horizontal,
              padding:          const EdgeInsets.fromLTRB(14, 0, 14, 12),
              itemCount:        photoUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    PageRouteBuilder<void>(
                      opaque: false,
                      pageBuilder: (_, __, ___) => _PhotoViewerPage(
                        photoUrls:    photoUrls,
                        initialIndex: i,
                      ),
                    ),
                  ),
                  child: Hero(
                    tag: 'photo_${photoUrls[i]}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: photoUrls[i],
                        width:    160,
                        height:   108,
                        fit:      BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 160,
                          color: Colors.grey.shade200,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 160,
                          color: Colors.grey.shade100,
                          child: const Icon(
                              Icons.broken_image_outlined,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Visor de fotos (pantalla completa) ───────────────────────────────────────

class _PhotoViewerPage extends StatefulWidget {
  final List<String> photoUrls;
  final int          initialIndex;
  const _PhotoViewerPage(
      {required this.photoUrls, required this.initialIndex});

  @override
  State<_PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<_PhotoViewerPage> {
  late PageController _ctrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl    = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:        Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('${_current + 1} / ${widget.photoUrls.length}',
            style: const TextStyle(fontSize: 14)),
      ),
      body: PageView.builder(
        controller:    _ctrl,
        itemCount:     widget.photoUrls.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (context, i) {
          return Center(
            child: Hero(
              tag: 'photo_${widget.photoUrls[i]}',
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl:    widget.photoUrls[i],
                  fit:         BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(
                        color: Colors.white),
                  ),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size:  64,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Banner programa de lealtad ───────────────────────────────────────────────

class _LoyaltyBanner extends StatelessWidget {
  final LoyaltyProgramModel program;
  const _LoyaltyBanner({required this.program});

  static final _fmt = DateFormat('dd/MM/yyyy', 'es_MX');

  @override
  Widget build(BuildContext context) {
    final daysLeft = program.daysLeft;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      color:  Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).restaurantLoyaltyProgram,
            style: TextStyle(
              fontSize:   10,
              fontWeight: FontWeight.w600,
              color:      Colors.grey.shade500,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(15),
                  AppColors.primary.withAlpha(5),
                ],
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withAlpha(40)),
            ),
            child: Row(
              children: [
                // Ícono
                Container(
                  width:  44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:        AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.loyalty,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 13,
                              color:    AppColors.textDark),
                          children: [
                            TextSpan(
                              text: '${AppLocalizations.of(context).restaurantVisitsCount(program.visitsRequired)} ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:      AppColors.primary),
                            ),
                            const TextSpan(text: '→ '),
                            TextSpan(
                                text: program.rewardDescription),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.event_outlined,
                              size:  11,
                              color: Colors.grey.shade500),
                          const SizedBox(width: 3),
                          Text(
                            daysLeft > 0
                                ? AppLocalizations.of(context).restaurantValidUntil(
                                    _fmt.format(program.endsAt), daysLeft)
                                : AppLocalizations.of(context).restaurantEnded(
                                    _fmt.format(program.endsAt)),
                            style: TextStyle(
                              fontSize: 10,
                              color:    daysLeft <= 7
                                  ? Colors.orange.shade700
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Sellos visuales (mini)
                Column(
                  children: List.generate(
                    (program.visitsRequired).clamp(1, 6),
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Icon(
                        Icons.local_cafe_outlined,
                        size:  10,
                        color: AppColors.primary.withAlpha(80),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // CTA
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => context.go('/stamps'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code_2,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 5),
                Text(
                  AppLocalizations.of(context).restaurantViewStampsAndQr,
                  style: const TextStyle(
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                    color:      AppColors.primary,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.chevron_right,
                    size: 14, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Promos activas (lista horizontal) ───────────────────────────────────────

class _PromosSection extends StatelessWidget {
  final List<PromotionModel>           promos;
  final void Function(PromotionModel)? onFavoriteToggled;

  const _PromosSection({
    required this.promos,
    this.onFavoriteToggled,
  });

  @override
  Widget build(BuildContext context) {
    // Día de la semana actual (1=Lun … 7=Dom), igual que activeDays
    final today = DateTime.now().weekday;

    // Promos activas hoy (o sin restricción de día / todos los días)
    final todayPromos = promos.where((p) =>
        p.activeDays.isEmpty ||
        p.activeDays.length == 7 ||
        p.activeDays.contains(today)).toList();

    // Promos de otros días de la semana
    final weekPromos = promos.where((p) =>
        p.activeDays.isNotEmpty &&
        p.activeDays.length < 7 &&
        !p.activeDays.contains(today)).toList();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      color:  Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado "Promociones activas" ──────────────────────────────
          Row(
            children: [
              Text(
                AppLocalizations.of(context).restaurantActivePromos,
                style: TextStyle(
                  fontSize:   10,
                  fontWeight: FontWeight.w600,
                  color:      Colors.grey.shade500,
                  letterSpacing: 0.4,
                ),
              ),
              if (todayPromos.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color:        AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${todayPromos.length}',
                    style: const TextStyle(
                      fontSize:   10,
                      fontWeight: FontWeight.bold,
                      color:      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // ── Promos de hoy ──────────────────────────────────────────────────
          if (todayPromos.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                weekPromos.isEmpty
                    ? AppLocalizations.of(context).restaurantNoActivePromos
                    : AppLocalizations.of(context).restaurantNoPromosToday,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade500),
              ),
            )
          else
            ...todayPromos.map((p) => _PromoListCard(
                  promo:             p,
                  onFavoriteToggled: onFavoriteToggled != null
                      ? () => onFavoriteToggled!(p)
                      : null,
                )),

          // ── Promos de otros días de la semana ──────────────────────────────
          if (weekPromos.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 11, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  AppLocalizations.of(context).restaurantAlsoThisWeek,
                  style: TextStyle(
                    fontSize:   10,
                    fontWeight: FontWeight.w600,
                    color:      Colors.grey.shade500,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...weekPromos.map((p) => _PromoListCard(
                  promo:             p,
                  onFavoriteToggled: onFavoriteToggled != null
                      ? () => onFavoriteToggled!(p)
                      : null,
                )),
          ],
        ],
      ),
    );
  }
}

// ─── Tarjeta de promo (lista horizontal) ─────────────────────────────────────

class _PromoListCard extends StatelessWidget {
  final PromotionModel promo;
  final VoidCallback?  onFavoriteToggled;

  const _PromoListCard({
    required this.promo,
    this.onFavoriteToggled,
  });

  static const _dayLabels = {
    1: 'Lun', 2: 'Mar', 3: 'Mié',
    4: 'Jue', 5: 'Vie', 6: 'Sáb', 7: 'Dom',
  };

  String get _daysText {
    if (promo.activeDays.isEmpty) return '';
    if (promo.activeDays.length == 7) return 'Todos los días';
    final sorted = [...promo.activeDays]..sort();
    // Rango consecutivo de 3+ días → "Lun – Vie"
    bool consecutive = true;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] - sorted[i - 1] != 1) { consecutive = false; break; }
    }
    if (consecutive && sorted.length >= 3) {
      return '${_dayLabels[sorted.first] ?? ''} – ${_dayLabels[sorted.last] ?? ''}';
    }
    return sorted.map((d) => _dayLabels[d] ?? '$d').join(', ');
  }

  String _formatTime(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return t;
    return '${parts[0]}:${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final isFlash = promo.type == 'flash';

    return GestureDetector(
      onTap: () => context.push<bool>('/promo/${promo.id}', extra: promo),
      child: Container(
        margin:      const EdgeInsets.only(bottom: 8),
        decoration:  BoxDecoration(
          color:        Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Imagen 64x64
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft:    Radius.circular(9),
                bottomLeft: Radius.circular(9),
              ),
              child: SizedBox(
                width:  64,
                height: 64,
                child: promo.photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: promo.photoUrl!,
                        fit:      BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            _PromoPlaceholder(isFlash: isFlash),
                      )
                    : _PromoPlaceholder(isFlash: isFlash),
              ),
            ),

            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre + badge flash
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            promo.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize:   13,
                              fontWeight: FontWeight.w600,
                              color:      AppColors.textDark,
                            ),
                          ),
                        ),
                        if (isFlash) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color:        AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt,
                                    size: 9, color: Color(0xFFFFD700)),
                                const SizedBox(width: 2),
                                Text(AppLocalizations.of(context).restaurantFlash,
                                    style: const TextStyle(
                                        fontSize:   9,
                                        fontWeight: FontWeight.w600,
                                        color:      Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Descripción corta
                    if (promo.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          promo.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color:    AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    // Días + horario
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (_daysText.isNotEmpty) ...[
                          Icon(Icons.calendar_today_outlined,
                              size:  10,
                              color: Colors.grey.shade500),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              _daysText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 10,
                                  color:    Colors.grey.shade500),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Icon(Icons.access_time_outlined,
                            size:  10,
                            color: Colors.grey.shade500),
                        const SizedBox(width: 3),
                        Text(
                          '${_formatTime(promo.startTime)}–'
                          '${_formatTime(promo.endTime)}',
                          style: TextStyle(
                              fontSize: 10,
                              color:    Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Favorito + chevron
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onFavoriteToggled != null)
                  GestureDetector(
                    onTap:       onFavoriteToggled,
                    behavior:    HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        promo.isFavorited
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size:  16,
                        color: promo.isFavorited
                            ? Colors.red.shade400
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(Icons.chevron_right,
                      size:  16,
                      color: Colors.grey.shade400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoPlaceholder extends StatelessWidget {
  final bool isFlash;
  const _PromoPlaceholder({required this.isFlash});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: isFlash
              ? [const Color(0xFF1A1A2E), AppColors.primary]
              : [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Center(
        child: Icon(
          isFlash ? Icons.bolt : Icons.local_offer_outlined,
          color: isFlash
              ? const Color(0xFFFFD700)
              : Colors.white.withAlpha(100),
          size: 24,
        ),
      ),
    );
  }
}

// ─── Helpers de contacto ──────────────────────────────────────────────────────

class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;

  const _ContactBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color:        color.withAlpha(18),
          border:       Border.all(color: color.withAlpha(80)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                    color:      color)),
          ],
        ),
      ),
    );
  }
}

class _ContactBtnFa extends StatelessWidget {
  final IconData faIcon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;

  const _ContactBtnFa({
    required this.faIcon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color:        color.withAlpha(18),
          border:       Border.all(color: color.withAlpha(80)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(faIcon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                    color:      color)),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;

  const _Chip({
    required this.icon,
    required this.label,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color:        Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
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
              color:      AppColors.textDark.withAlpha(180),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fondo gradiente ─────────────────────────────────────────────────────────

class _GradientBg extends StatelessWidget {
  const _GradientBg();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: const Center(
        child: Icon(Icons.restaurant_menu,
            size: 64, color: Colors.white24),
      ),
    );
  }
}

// ─── Scaffolds de carga / error ───────────────────────────────────────────────

class _LoadingScaffold extends StatelessWidget {
  final String name;
  const _LoadingScaffold({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      backgroundColor: AppColors.background,
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String message;
  const _ErrorScaffold({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<RestaurantDetailCubit>().load(),
              child: Text(AppLocalizations.of(context).restaurantRetry),
            ),
          ],
        ),
      ),
    );
  }
}
