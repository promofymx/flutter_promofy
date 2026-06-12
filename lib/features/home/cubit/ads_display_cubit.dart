import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/ads_repository.dart';
import 'ads_display_state.dart';

/// Carga los anuncios activos que se muestran al usuario final (no al negocio).
/// Diseñado para cargarse una sola vez al montar el shell principal.
class AdsDisplayCubit extends Cubit<AdsDisplayState> {
  final AdsRepository _repo;

  AdsDisplayCubit({AdsRepository? repository})
      : _repo = repository ?? AdsRepository(),
        super(const AdsDisplayState());

  /// Última ubicación conocida del usuario (se usa para enriquecer la promo
  /// anunciada en la card patrocinada: distancia real, etc.).
  double? lastLat;
  double? lastLng;

  /// Carga anuncios rankeados por relevancia.
  /// Pasa [lat] y [lng] cuando estén disponibles para activar el factor distancia.
  Future<void> load({double? lat, double? lng}) async {
    lastLat = lat;
    lastLng = lng;
    try {
      final ads = await _repo.getAdsForUser(lat: lat, lng: lng, limit: 10);

      // Rotación: cada apertura avanza un offset persistido para alternar a los
      // anunciantes que pagan por el mismo espacio. Así no sale siempre el #1:
      // al cerrar y reabrir la app aparece otro establecimiento.
      final offset = await _nextRotationOffset();
      final splashAds   = _rotate(
          ads.where((a) => a.format == 'splash').toList(), offset);
      final bannerAds   = _rotate(
          ads.where((a) => a.format == 'banner').toList(), offset);
      final featuredAds = _rotate(
          ads.where((a) => a.format == 'featured_list').toList(), offset);

      emit(AdsDisplayState(
        splashAds:   splashAds,
        bannerAds:   bannerAds,
        featuredAds: featuredAds,
        loaded:      true,
      ));

      // Impresión SOLO de los que realmente se muestran (antes se cobraban
      // todos los traídos → sobrecobro a quien no se mostraba). Splash y banner
      // muestran 1; el grid cicla por todos los featured.
      final shown = <String>{};
      if (splashAds.isNotEmpty) shown.add(splashAds.first.id);
      if (bannerAds.isNotEmpty) shown.add(bannerAds.first.id);
      for (final ad in featuredAds) {
        shown.add(ad.id);
      }
      for (final id in shown) {
        trackImpression(id);
      }
    } catch (_) {
      // Fallo silencioso — la app funciona sin anuncios.
      emit(const AdsDisplayState(loaded: true));
    }
  }

  /// Rota la lista [offset] posiciones (round-robin) para alternar anunciantes.
  List<T> _rotate<T>(List<T> list, int offset) {
    if (list.length <= 1) return list;
    final k = offset % list.length;
    return [...list.sublist(k), ...list.sublist(0, k)];
  }

  /// Devuelve el offset actual de rotación y lo incrementa para la próxima vez.
  Future<int> _nextRotationOffset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cur = prefs.getInt('ads_rotation_offset') ?? 0;
      await prefs.setInt('ads_rotation_offset', cur + 1);
      return cur;
    } catch (_) {
      return 0;
    }
  }

  // ── Phase D: tracking de impresiones ─────────────────────────────────────

  /// Registra que el anuncio fue mostrado al usuario (CPM → débito de crédito).
  /// Fire-and-forget: los errores se ignoran para no interrumpir la UX.
  void trackImpression(String campaignId) {
    _repo.recordImpression(campaignId, 'impression').catchError((_) {});
  }

  /// Registra que el usuario tocó el anuncio (clic).
  void trackClick(String campaignId) {
    _repo.recordImpression(campaignId, 'click').catchError((_) {});
  }
}
