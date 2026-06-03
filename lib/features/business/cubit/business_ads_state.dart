import 'package:equatable/equatable.dart';
import '../../../data/models/ad_campaign_model.dart';
import '../../../data/models/ad_credit_model.dart';
import '../../../data/models/ad_credit_txn_model.dart';
import '../../../data/models/ad_pricing_model.dart';

abstract class BusinessAdsState extends Equatable {
  const BusinessAdsState();
  @override
  List<Object?> get props => [];
}

class BusinessAdsInitial extends BusinessAdsState {
  const BusinessAdsInitial();
}

class BusinessAdsLoading extends BusinessAdsState {
  const BusinessAdsLoading();
}

class BusinessAdsLoaded extends BusinessAdsState {
  final AdCreditModel?          credit;
  final List<AdCampaignModel>   campaigns;
  final List<AdCreditTxnModel>  transactions;
  final List<AdPricingModel>    pricing;
  final int                     totalUserCount;

  const BusinessAdsLoaded({
    required this.credit,
    required this.campaigns,
    required this.transactions,
    required this.pricing,
    required this.totalUserCount,
  });

  /// Campañas activas o pausadas (en curso).
  List<AdCampaignModel> get activeCampaigns =>
      campaigns.where((c) => c.isActive || c.isPaused).toList();

  /// Alcance estimado con el saldo actual para un formato dado.
  /// Retorna -1 si no hay precio disponible o no hay saldo.
  int estimatedReach(String format) {
    if (credit == null || credit!.balanceMxn <= 0) return 0;
    final p = pricing.where((x) => x.format == format).firstOrNull;
    if (p == null || p.priceMxn <= 0) return 0;
    final unit = p.effectiveBillingUnit(totalUserCount);
    return ((credit!.balanceMxn / p.priceMxn) * unit).floor();
  }

  BusinessAdsLoaded copyWith({
    AdCreditModel?         credit,
    List<AdCampaignModel>? campaigns,
    List<AdCreditTxnModel>? transactions,
  }) {
    return BusinessAdsLoaded(
      credit:         credit       ?? this.credit,
      campaigns:      campaigns    ?? this.campaigns,
      transactions:   transactions ?? this.transactions,
      pricing:        pricing,
      totalUserCount: totalUserCount,
    );
  }

  @override
  List<Object?> get props =>
      [credit, campaigns, transactions, pricing, totalUserCount];
}

class BusinessAdsError extends BusinessAdsState {
  final String message;
  const BusinessAdsError(this.message);
  @override
  List<Object?> get props => [message];
}
