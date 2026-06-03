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

  Future<void> load() async {
    try {
      final ads = await _repo.getActiveAdsForDisplay();
      emit(AdsDisplayState(
        splashAds:   ads.where((a) => a.format == 'splash').toList(),
        bannerAds:   ads.where((a) => a.format == 'banner').toList(),
        featuredAds: ads.where((a) => a.format == 'featured_list').toList(),
        loaded:      true,
      ));
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
