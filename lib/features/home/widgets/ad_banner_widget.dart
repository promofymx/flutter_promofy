import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/ads_display_cubit.dart';
import '../cubit/ads_display_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/ad_display_model.dart';

/// Banner horizontal que aparece entre los filtros y el grid del Home.
/// Solo se muestra si hay al menos una campaña "banner" activa.
class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdsDisplayCubit, AdsDisplayState>(
      buildWhen: (prev, next) => prev.bannerAds != next.bannerAds,
      builder: (context, state) {
        if (state.bannerAds.isEmpty) return const SizedBox.shrink();
        return _AdBannerCard(ad: state.bannerAds.first);
      },
    );
  }
}

class _AdBannerCard extends StatelessWidget {
  final AdDisplayModel ad;
  const _AdBannerCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/restaurant/${ad.establishmentId}',
        extra: ad.establishmentName,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 2),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Imagen del establecimiento ──────────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
              child: SizedBox(
                width: 80,
                height: 72,
                child: ad.photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: ad.photoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const _BannerPlaceholder(),
                        errorWidget: (_, __, ___) =>
                            const _BannerPlaceholder(),
                      )
                    : const _BannerPlaceholder(),
              ),
            ),

            // ── Texto ───────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.establishmentName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Ver sus promociones',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            // ── Label "Publicidad" + chevron ────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'Publicidad',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withAlpha(20),
      child: const Center(
        child: Icon(Icons.store, color: AppColors.primary, size: 28),
      ),
    );
  }
}
