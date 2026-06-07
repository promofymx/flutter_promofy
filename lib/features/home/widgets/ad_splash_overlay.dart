import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:promofy/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/ad_display_model.dart';

/// Card compacta de splash publicitario.
/// Se muestra como [Dialog] con fondo oscurecido, no pantalla completa.
/// Cierra automáticamente a los [_kDuration] segundos o por interacción.
///
/// [onImpression] se llama una sola vez al mostrarse (Phase D — CPM tracking).
/// [onClick] se llama cuando el usuario toca "Ver promociones" (estadísticas).
class AdSplashOverlay extends StatefulWidget {
  final AdDisplayModel ad;
  final VoidCallback?  onImpression;
  final VoidCallback?  onClick;
  const AdSplashOverlay({
    super.key,
    required this.ad,
    this.onImpression,
    this.onClick,
  });

  @override
  State<AdSplashOverlay> createState() => _AdSplashOverlayState();
}

class _AdSplashOverlayState extends State<AdSplashOverlay> {
  static const _kDuration = 3;
  int    _remaining = _kDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Phase D: registrar impresión al mostrarse el anuncio.
    widget.onImpression?.call();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) _close();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _close() {
    _timer?.cancel();
    if (mounted) Navigator.of(context).pop();
  }

  void _visit() {
    // Phase D: registrar clic antes de navegar.
    widget.onClick?.call();
    _close();
    Future.microtask(() {
      if (mounted) {
        context.push(
          '/restaurant/${widget.ad.establishmentId}',
          extra: widget.ad.establishmentName,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ColoredBox(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Foto + overlays ─────────────────────────────────────────
            Stack(
              children: [
                SizedBox(
                  height: 210,
                  width:  double.infinity,
                  child: widget.ad.displayPhotoUrl != null
                      ? CachedNetworkImage(
                          imageUrl:    widget.ad.displayPhotoUrl!,
                          fit:         BoxFit.cover,
                          placeholder: (_, __) => const _CardPlaceholder(),
                          errorWidget: (_, __, ___) => const _CardPlaceholder(),
                        )
                      : const _CardPlaceholder(),
                ),

                // Degradado inferior sobre la foto
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin:  Alignment.topCenter,
                        end:    Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(160),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Nombre del negocio/promo sobre la foto
                Positioned(
                  left: 16, right: 56, bottom: 14,
                  child: Text(
                    widget.ad.displayTitle,
                    style: const TextStyle(
                      color:      Colors.white,
                      fontSize:   20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
                    ),
                    maxLines:  2,
                    overflow:  TextOverflow.ellipsis,
                  ),
                ),

                // Badge "Publicidad" top-left
                Positioned(
                  top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color:        Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalizations.of(context).adSplashAdLabel,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 10),
                    ),
                  ),
                ),

                // Botón cerrar con cuenta regresiva top-right
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: _remaining <= 0 ? _close : null,
                    child: Container(
                      width:  36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _remaining > 0
                            ? Text(
                                '$_remaining',
                                style: const TextStyle(
                                  color:      Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:   14,
                                ),
                              )
                            : const Icon(
                                Icons.close,
                                color: Colors.white,
                                size:  18,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Contenido inferior ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.ad.isPromotionAd
                        ? AppLocalizations.of(context)
                            .adSplashPromoSpecial(widget.ad.establishmentName)
                        : AppLocalizations.of(context).adSplashDiscoverMsg,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize:     Size.zero,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _visit,
                    child: Text(
                      AppLocalizations.of(context).adSplashViewPromos,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
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

class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder();
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
        child: Icon(Icons.store, size: 56, color: Colors.white24),
      ),
    );
  }
}
