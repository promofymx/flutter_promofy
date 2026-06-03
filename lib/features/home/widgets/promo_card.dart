import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/promotion_model.dart';
import '../../../core/theme/app_theme.dart';

class PromoCard extends StatelessWidget {
  final PromotionModel  promo;
  /// Si es null el botón de favorito se oculta (útil en vistas de solo lectura)
  final VoidCallback?   onFavoriteToggled;
  final VoidCallback?   onTap;

  const PromoCard({
    super.key,
    required this.promo,
    this.onFavoriteToggled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            _ImageSection(promo: promo),
            _InfoSection(
              promo: promo,
              onFavoriteToggled: onFavoriteToggled,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sección imagen ────────────────────────────────────────────────
class _ImageSection extends StatelessWidget {
  final PromotionModel promo;
  const _ImageSection({required this.promo});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: 120,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Foto o gradiente con ícono
            promo.photoUrl != null
                ? CachedNetworkImage(
                    imageUrl: promo.photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const _GradientPlaceholder(),
                    errorWidget: (_, __, ___) => const _GradientPlaceholder(),
                  )
                : const _GradientPlaceholder(),

            // Badge contador de favoritos (esquina superior derecha)
            Positioned(
              top: 8,
              right: 8,
              child: _CountBadge(count: promo.favoritesCount),
            ),

            // Badges superior izquierda: Destacada y/o Relámpago
            if (promo.isFeatured || promo.isFlash)
              Positioned(
                top: 8,
                left: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (promo.isFeatured) const _FeaturedBadge(),
                    if (promo.isFeatured && promo.isFlash)
                      const SizedBox(height: 4),
                    if (promo.isFlash) _FlashBadge(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GradientPlaceholder extends StatelessWidget {
  const _GradientPlaceholder();

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
        child: Icon(
          Icons.restaurant_menu,
          size: 44,
          color: Colors.white24,
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 11),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlashBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, color: Colors.white, size: 12),
          SizedBox(width: 2),
          Text(
            'Relámpago',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedBadge extends StatelessWidget {
  const _FeaturedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB300), // ámbar dorado
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.white, size: 12),
          SizedBox(width: 2),
          Text(
            'Destacada',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sección de información ────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final PromotionModel promo;
  final VoidCallback?  onFavoriteToggled;

  const _InfoSection({
    required this.promo,
    this.onFavoriteToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del restaurante
          Text(
            promo.establishmentName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 3),

          // Distancia
          if (promo.distanceFormatted.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 11, color: Colors.grey),
                const SizedBox(width: 2),
                Text(
                  promo.distanceFormatted,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey),
                ),
              ],
            ),

          const SizedBox(height: 4),

          // Nombre de la promo — siempre 2 líneas para que el pie sea constante
          SizedBox(
            height: 36,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.local_offer,
                    size: 11,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    promo.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Fila: rating + WhatsApp + favorito
          Row(
            children: [
              const Icon(Icons.star, size: 13, color: Color(0xFFFFC107)),
              const SizedBox(width: 2),
              Text(
                promo.displayRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              if (!promo.hasRealRating) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Nuevo',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Spacer(),

              // Compartir promo
              GestureDetector(
                onTap: () => _sharePromo(promo),
                child: const Icon(
                  Icons.share_outlined,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 10),

              // Favorito (oculto si no se provee callback)
              if (onFavoriteToggled != null)
                GestureDetector(
                  onTap: onFavoriteToggled,
                  child: Icon(
                    promo.isFavorited
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 20,
                    color: promo.isFavorited
                        ? AppColors.primary
                        : Colors.grey,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Helper compartir ─────────────────────────────────────────────────────────

Future<void> _sharePromo(PromotionModel promo) async {
  final encoded = Uri.encodeComponent(promo.whatsAppText);
  final url = Uri.parse('https://wa.me/?text=$encoded');
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}