import 'package:equatable/equatable.dart';
import '../../../data/models/ad_display_model.dart';

class AdsDisplayState extends Equatable {
  final List<AdDisplayModel> splashAds;
  final List<AdDisplayModel> bannerAds;
  final List<AdDisplayModel> featuredAds;
  final bool loaded;

  const AdsDisplayState({
    this.splashAds   = const [],
    this.bannerAds   = const [],
    this.featuredAds = const [],
    this.loaded      = false,
  });

  @override
  List<Object?> get props => [splashAds, bannerAds, featuredAds, loaded];
}
