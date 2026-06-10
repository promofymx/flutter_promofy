import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:promofy/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/supabase/promotions_datasource.dart';
import '../../../data/models/ad_display_model.dart';
import '../../../data/models/promotion_model.dart';
import '../../../main.dart';
import '../cubit/ads_display_cubit.dart';
import 'promo_card.dart';

/// Card patrocinada que se intercala en el grid del Home cada 5 promos.
///
/// • Anuncio de **promoción**: se muestra una [PromoCard] idéntica a las demás
///   (misma imagen, datos, distancia, rating y favorito), añadiendo solo el
///   identificador "Patrocinado". La promo se enriquece via el mismo RPC del
///   feed para obtener distancia/rating/favoritos reales aunque esté lejos.
/// • Anuncio de **establecimiento**: card con logo + nombre + "Patrocinado".
class SponsoredPromoCard extends StatefulWidget {
  final AdDisplayModel ad;
  const SponsoredPromoCard({super.key, required this.ad});

  @override
  State<SponsoredPromoCard> createState() => _SponsoredPromoCardState();
}

class _SponsoredPromoCardState extends State<SponsoredPromoCard> {
  final _ds = PromotionsDatasource();
  PromotionModel? _promo; // promo enriquecida (solo anuncios de promoción)
  bool _favBusy = false;

  @override
  void initState() {
    super.initState();
    // Registrar impresión una sola vez al renderizarse la card (CPM → débito).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdsDisplayCubit>().trackImpression(widget.ad.id);
    });
    if (widget.ad.isPromotionAd) _loadPromo();
  }

  /// Trae la promo anunciada con todos sus datos calculados (distancia, rating,
  /// favoritos) reutilizando el RPC del feed con filtro por establecimiento
  /// (radio amplio → la trae aunque esté más lejos que las que se ven).
  Future<void> _loadPromo() async {
    final cubit = context.read<AdsDisplayCubit>();
    final lat = cubit.lastLat;
    final lng = cubit.lastLng;
    if (lat == null || lng == null) return; // sin ubicación → fallback
    try {
      final promos = await _ds.getByDistance(
        lat: lat,
        lng: lng,
        limit: 50,
        userId: supabase.auth.currentUser?.id,
        filterEstablishmentId: widget.ad.establishmentId,
      );
      final match =
          promos.where((p) => p.id == widget.ad.promotionId).toList();
      if (mounted && match.isNotEmpty) {
        setState(() => _promo = match.first);
      }
    } catch (_) {
      // Silencioso: se mantiene la card de respaldo.
    }
  }

  void _open() {
    context.read<AdsDisplayCubit>().trackClick(widget.ad.id);
    final p = _promo;
    if (p != null) {
      context.push('/promo/${p.id}', extra: p);
    } else {
      context.push(
        '/restaurant/${widget.ad.establishmentId}',
        extra: widget.ad.establishmentName,
      );
    }
  }

  Future<void> _toggleFav() async {
    final p = _promo;
    final uid = supabase.auth.currentUser?.id;
    if (p == null || uid == null || _favBusy) return;
    _favBusy = true;
    final next = !p.isFavorited;
    final previous = p;
    // Actualización optimista
    setState(() => _promo = p.copyWith(
          isFavorited: next,
          favoritesCount:
              (p.favoritesCount + (next ? 1 : -1)).clamp(0, 1 << 30).toInt(),
        ));
    try {
      if (next) {
        await _ds.addFavorite(uid, p.id);
      } else {
        await _ds.removeFavorite(uid, p.id);
      }
    } catch (_) {
      if (mounted) setState(() => _promo = previous); // revertir
    } finally {
      _favBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final promo = _promo;

    // ── Anuncio de promoción: card idéntica + badge "Patrocinado" ──────────
    if (promo != null) {
      return Stack(
        children: [
          PromoCard(
            promo: promo,
            onTap: _open,
            onFavoriteToggled: _toggleFav,
          ),
          Positioned(
            top: 8,
            left: 8,
            child: IgnorePointer(child: _PatrocinadoBadge()),
          ),
        ],
      );
    }

    // ── Anuncio de establecimiento (o promo cargando) ──────────────────────
    return GestureDetector(
      onTap: _open,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.secondary.withAlpha(80), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(18),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SponsoredImageSection(ad: widget.ad),
            _SponsoredInfoSection(ad: widget.ad),
          ],
        ),
      ),
    );
  }
}

// ── Badge "Patrocinado" superpuesto sobre la PromoCard ─────────────────────────

class _PatrocinadoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_outline, color: Colors.white, size: 11),
          const SizedBox(width: 3),
          Text(
            AppLocalizations.of(context).sponsoredCardBadge,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sección imagen (anuncio de establecimiento) ────────────────────────────────

class _SponsoredImageSection extends StatelessWidget {
  final AdDisplayModel ad;
  const _SponsoredImageSection({required this.ad});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: 120,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ad.displayPhotoUrl != null
                ? Container(
                    // Promo → foto a sangre (cover). Establecimiento → logo
                    // contenido sobre fondo claro (no recortado).
                    color: ad.isPromotionAd ? null : Colors.grey.shade50,
                    padding: ad.isPromotionAd
                        ? EdgeInsets.zero
                        : const EdgeInsets.all(16),
                    child: CachedNetworkImage(
                      imageUrl: ad.displayPhotoUrl!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: ad.isPromotionAd ? BoxFit.cover : BoxFit.contain,
                      placeholder: (_, __) => const _SponsoredPlaceholder(),
                      errorWidget: (_, __, ___) => const _SponsoredPlaceholder(),
                    ),
                  )
                : const _SponsoredPlaceholder(),

            // Badge "Patrocinado"
            Positioned(
              top: 8,
              left: 8,
              child: _PatrocinadoBadge(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sección de información (anuncio de establecimiento) ─────────────────────────

class _SponsoredInfoSection extends StatelessWidget {
  final AdDisplayModel ad;
  const _SponsoredInfoSection({required this.ad});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ad.displayTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            ad.isPromotionAd
                ? ad.establishmentName
                : AppLocalizations.of(context).sponsoredCardSeePromotions,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              AppLocalizations.of(context).sponsoredCardAd,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SponsoredPlaceholder extends StatelessWidget {
  const _SponsoredPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withAlpha(180),
            AppColors.primary.withAlpha(180),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.store, size: 40, color: Colors.white24),
      ),
    );
  }
}
