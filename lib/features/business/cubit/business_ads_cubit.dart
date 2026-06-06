import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/ad_campaign_model.dart';
import '../../../data/repositories/ads_repository.dart';
import 'business_ads_state.dart';

class BusinessAdsCubit extends Cubit<BusinessAdsState> {
  final AdsRepository _repo;
  final String        _establishmentId;
  final String        _userId;

  BusinessAdsCubit({
    required String establishmentId,
    required String userId,
    AdsRepository?  repository,
  })  : _repo            = repository ?? AdsRepository(),
        _establishmentId = establishmentId,
        _userId          = userId,
        super(const BusinessAdsInitial());

  // ── Carga ──────────────────────────────────────────────────────────────────

  Future<void> load() async {
    emit(const BusinessAdsLoading());
    try {
      final results = await Future.wait([
        _repo.getCredits(_establishmentId),
        _repo.getCampaigns(_establishmentId),
        _repo.getTransactions(_establishmentId),
        _repo.getPricing(),
        _repo.getTotalUserCount(),
      ]);

      emit(BusinessAdsLoaded(
        credit:         results[0] as dynamic,
        campaigns:      (results[1] as List).cast<AdCampaignModel>(),
        transactions:   (results[2] as List).cast(),
        pricing:        (results[3] as List).cast(),
        totalUserCount: results[4] as int,
      ));
    } catch (e) {
      emit(BusinessAdsError(e.toString()));
    }
  }

  // ── Crear campaña ──────────────────────────────────────────────────────────

  Future<void> createCampaign({
    required String   name,
    required String   format,
    required double   budgetMxn,
    required int      radiusKm,
    required String   geoMode,
    List<int>?        targetCategoryIds,
    int     targetMinAge  = 0,
    int     targetMaxAge  = 99,
    String  targetGender  = 'all',
    String? promotionId,
    List<String>?     placements,
    DateTime?         startDate,
    DateTime?         endDate,
  }) async {
    final current = state;
    if (current is! BusinessAdsLoaded) return;

    final campaign = await _repo.createCampaign(
      establishmentId:   _establishmentId,
      createdBy:         _userId,
      name:              name,
      format:            format,
      budgetMxn:         budgetMxn,
      radiusKm:          radiusKm,
      geoMode:           geoMode,
      targetCategoryIds: targetCategoryIds,
      targetMinAge:      targetMinAge,
      targetMaxAge:      targetMaxAge,
      targetGender:      targetGender,
      promotionId:       promotionId,
      placements:        placements,
      startDate:         startDate,
      endDate:           endDate,
    );

    emit(current.copyWith(
      campaigns: [campaign, ...current.campaigns],
    ));

    // Si es de formato push, dispara el envío a la audiencia y cobra. Best-effort:
    // la campaña ya quedó creada aunque el envío falle.
    if (format == 'push') {
      try {
        await _repo.sendAdPush(campaign.id);
        final refreshed = await _repo.getCampaigns(_establishmentId);
        final st = state;
        if (st is BusinessAdsLoaded) emit(st.copyWith(campaigns: refreshed));
      } catch (_) {/* sin interrumpir el flujo */}
    }
  }

  // ── Pausar / reanudar campaña ──────────────────────────────────────────────

  Future<void> toggleCampaignStatus(AdCampaignModel campaign) async {
    final current = state;
    if (current is! BusinessAdsLoaded) return;

    final newStatus = campaign.isActive ? 'paused' : 'active';
    final updated   = await _repo.updateCampaignStatus(campaign.id, newStatus);

    emit(current.copyWith(
      campaigns: current.campaigns
          .map((c) => c.id == updated.id ? updated : c)
          .toList(),
    ));
  }
}
