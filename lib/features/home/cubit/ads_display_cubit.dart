import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/ads_repository.dart';
import 'ads_display_state.dart';

/// Carga los anuncios activos que se muestran al usuario final (no al negocio).
/// Diseñado para cargarse una sola vez al montar el shell principal.
class AdsDisplayCubit extends Cubit<AdsDisplayState> {
  final AdsRepository _repo;

  AdsDisplayCubit({AdsRepository? repository})
      : _repo = repository ?? AdsRepository(),
        super(const AdsDisplayState());

  /// Carga anuncios rankeados por relevancia.
  /// Pasa [lat] y [lng] cuando estén disponibles para activar el factor distancia.
  Future<void> load({double? lat, double? lng}) async {
    try {
      final ads = await _repo.getAdsForUser(lat: lat, lng: lng, limit: 10);
      final splashAds   = ads.where((a) => a.format == 'splash').toList();
      final bannerAds   = ads.where((a) => a.format == 'banner').toList();
      final featuredAds = ads.where((a) => a.format == 'featured_list').toList();
      emit(AdsDisplayState(
        splashAds:   splashAds,
        bannerAds:   bannerAds,
        featuredAds: featuredAds,
        loaded:      true,
      ));

      // Registrar una impresión por cada anuncio servido. El servidor
      // deduplica por usuario/campaña/día, así que dispararlas en cada carga
      // no genera sobrecobro pero garantiza que el conteo avance aunque el
      // feed se mantenga vivo (keep-alive) y los widgets no se re-monten.
      for (final ad in ads) {
        trackImpression(ad.id);
      }
    } catch (_) {
      // Fallo silencioso — la app funciona sin anuncios.
      emit(const AdsDisplayState(loaded: true));
    }
  }

  // ── Phase D: tracking de impresiones ─────────────────────────────────────

  /// Registra que el anuncio fue mostrado al usuario (CPM → débito de crédito).
  /// Fire-and-forget: los errores se ignoran para no interrumpir la UX.
  void trackImpression(String campaignId) {
    _repo.recordImpression(campaignId, 'impression').catchError((_) {});
  }

  /// Registra que el usuario tocó el anuncio (clic). Solo estadísticas, sin cobro.
  void trackClick(String campaignId) {
    _repo.recordImpression(campaignId, 'click').catchError((_) {});
  }
}
