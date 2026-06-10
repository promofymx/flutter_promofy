import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:promofy/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/report_sheet.dart';
import '../../../data/models/promotion_model.dart';
import '../../../data/repositories/promotions_repository.dart';
import '../../../data/repositories/stats_repository.dart';


class PromoDetailScreen extends StatefulWidget {
  final PromotionModel promo;
  final String?        userId;

  const PromoDetailScreen({super.key, required this.promo, this.userId});

  @override
  State<PromoDetailScreen> createState() => _PromoDetailScreenState();
}

class _PromoDetailScreenState extends State<PromoDetailScreen> {
  late bool _isFavorited;
  late int  _favoritesCount;
  bool      _isSaving = false;

  final _repo      = PromotionsRepository();
  final _statsRepo = StatsRepository();

  @override
  void initState() {
    super.initState();
    _isFavorited    = widget.promo.isFavorited;
    _favoritesCount = widget.promo.favoritesCount;
    // Registra la vista de la promo (fire-and-forget)
    _statsRepo.logPromoView(widget.promo.id);
  }

  /// Cierra la pantalla pasando el estado final del favorito como resultado.
  /// HomeScreen lo usa para sincronizar la card sin volver a llamar a la API.
  void _pop() => context.pop(_isFavorited);

  /// Toggle real: actualización optimista + llamada al repositorio.
  Future<void> _toggleFavorite() async {
    if (_isSaving) return;

    setState(() {
      _isSaving        = true;
      _favoritesCount += _isFavorited ? -1 : 1;
      _isFavorited     = !_isFavorited;
    });

    if (widget.userId != null) {
      try {
        // Usamos widget.promo (estado original) para que el repositorio
        // sepa si debe hacer INSERT o DELETE.
        await _repo.toggleFavorite(
          userId: widget.userId!,
          promo:  widget.promo,
        );
      } catch (_) {
        // Revertir si falla
        if (mounted) {
          setState(() {
            _favoritesCount += _isFavorited ? -1 : 1;
            _isFavorited     = !_isFavorited;
          });
        }
      }
    }

    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _shareWhatsApp() async {
    final encoded = Uri.encodeComponent(widget.promo.whatsAppText);
    final url     = Uri.parse('https://wa.me/?text=$encoded');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final promo = widget.promo;

    // PopScope intercepta tanto el botón de sistema como el leading del AppBar,
    // asegurando que siempre se pase _isFavorited como resultado al hacer pop.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            // ── Header con imagen colapsable ─────────────────────────────
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              // Botón back explícito para controlar el resultado del pop
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _pop,
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (v) {
                    if (v == 'report') {
                      showReportSheet(
                        context,
                        contentType: 'promotion',
                        contentId:   promo.id,
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
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Foto o gradiente
                    promo.photoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: promo.photoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                const _GradientBg(),
                            errorWidget: (_, __, ___) =>
                                const _GradientBg(),
                          )
                        : const _GradientBg(),

                    // Gradiente inferior para legibilidad del texto
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end:   Alignment.bottomCenter,
                          stops: [0.4, 1.0],
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),

                    // Badge relámpago
                    if (promo.isFlash)
                      Positioned(
                        top: 72,
                        left: 16,
                        child: _FlashBadge(promo: promo),
                      ),

                    // Nombre del establecimiento — tappable para ir al detalle
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: GestureDetector(
                        onTap: () => context.push(
                          '/restaurant/${promo.establishmentId}',
                          extra: promo.establishmentName,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                promo.establishmentName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                        blurRadius: 4,
                                        color: Colors.black38),
                                  ],
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: Colors.white70, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Contenido ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre de la promo
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(Icons.local_offer,
                              size: 16, color: AppColors.primary),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            promo.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Meta chips: distancia · rating · favoritos
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        if (promo.distanceFormatted.isNotEmpty)
                          _MetaChip(
                            icon: Icons.location_on_outlined,
                            label: promo.distanceFormatted,
                          ),
                        _MetaChip(
                          icon: Icons.star_rounded,
                          label: promo.displayRating.toStringAsFixed(1),
                          iconColor: const Color(0xFFFFC107),
                          suffix: promo.hasRealRating
                              ? null
                              : ' · ${AppLocalizations.of(context).promoDetailNew}',
                        ),
                        _MetaChip(
                          icon: Icons.favorite_rounded,
                          label: '$_favoritesCount',
                          iconColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Botón ir al restaurante
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.push(
                          '/restaurant/${promo.establishmentId}',
                          extra: promo.establishmentName,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.store_outlined,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                promo.establishmentName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right,
                                size: 20, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Tarjeta de regalo de cumpleaños ──────────────────
                    if (promo.isBirthday &&
                        (promo.birthdayGift != null ||
                            promo.birthdayTerms != null)) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF3E0), Color(0xFFFFF8E1)],
                            begin: Alignment.topLeft,
                            end:   Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.orange.shade200, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Text('🎁',
                                  style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context).promoDetailBirthdayGift,
                                style: TextStyle(
                                  fontSize:   15,
                                  fontWeight: FontWeight.bold,
                                  color:      Colors.orange.shade800,
                                ),
                              ),
                            ]),
                            if (promo.birthdayGift != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                promo.birthdayGift!,
                                style: const TextStyle(
                                    fontSize: 14, height: 1.5),
                              ),
                            ],
                            if (promo.birthdayTerms != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                AppLocalizations.of(context).promoDetailConditions(promo.birthdayTerms!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Descripción
                    if (promo.description.isNotEmpty) ...[
                      Text(
                        AppLocalizations.of(context).promoDetailDescription,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        promo.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark.withAlpha(180),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Horario y días
                    Text(
                      AppLocalizations.of(context).promoDetailAvailability,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ScheduleRow(promo: promo),
                    const SizedBox(height: 24),

                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // Botones de acción
                    Row(
                      children: [
                        // WhatsApp
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _shareWhatsApp,
                            icon: const FaIcon(
                                FontAwesomeIcons.whatsapp,
                                size: 18,
                                color: Color(0xFF25D366)),
                            label: Text(
                              AppLocalizations.of(context).promoDetailShare,
                              style: const TextStyle(
                                  color: AppColors.textDark),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Favorito
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _toggleFavorite,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    _isFavorited
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              _isFavorited
                                  ? AppLocalizations.of(context).promoDetailSaved
                                  : AppLocalizations.of(context).promoDetailSave,
                              style: const TextStyle(
                                  color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFavorited
                                  ? AppColors.primary
                                  : Colors.grey.shade700,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
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

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _GradientBg extends StatelessWidget {
  const _GradientBg();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: const Center(
        child: Icon(Icons.restaurant_menu,
            size: 72, color: Colors.white24),
      ),
    );
  }
}

class _FlashBadge extends StatelessWidget {
  final PromotionModel promo;
  const _FlashBadge({required this.promo});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final endsAt = promo.flashEndsAt;
    final l10n = AppLocalizations.of(context);
    String label = l10n.promoDetailFlash;
    if (endsAt != null && endsAt.isAfter(now)) {
      final diff = endsAt.difference(now);
      if (diff.inHours > 0) {
        label = l10n.promoDetailFlashEndsInHours(
            diff.inHours, diff.inMinutes % 60);
      } else {
        label = l10n.promoDetailFlashEndsInMinutes(diff.inMinutes);
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    iconColor;
  final String?  suffix;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.iconColor = Colors.grey,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            '$label${suffix ?? ''}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textDark.withAlpha(180),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final PromotionModel promo;
  const _ScheduleRow({required this.promo});

  static const _dayNames = {
    1: 'Lun', 2: 'Mar', 3: 'Mié',
    4: 'Jue', 5: 'Vie', 6: 'Sáb', 7: 'Dom',
  };

  @override
  Widget build(BuildContext context) {
    final time =
        '${promo.startTime.substring(0, 5)} – ${promo.endTime.substring(0, 5)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Días de la semana como chips
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(7, (i) {
            final day     = i + 1;
            final active  = promo.activeDays.contains(day);
            return Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                _dayNames[day]!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : Colors.grey,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        // Horario
        Row(
          children: [
            const Icon(Icons.access_time_outlined,
                size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              time,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textDark),
            ),
          ],
        ),
      ],
    );
  }
}
