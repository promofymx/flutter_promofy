import 'package:equatable/equatable.dart';

/// Modelo ligero para renderizar un anuncio al usuario final.
/// Se obtiene via RPC get_ads_for_user (campos planos).
class AdDisplayModel extends Equatable {
  final String  id;               // campaign id
  final String  establishmentId;
  final String  establishmentName;
  final String? photoUrl;         // foto del establecimiento
  final String? logoUrl;          // logo del establecimiento
  final String  format;           // splash | featured_list | banner
  final double  score;            // relevance score 0–100

  // Campos de promoción (presentes cuando la campaña publicita una promo)
  final String? promotionId;
  final String? promotionName;
  final String? promotionPhotoUrl;

  const AdDisplayModel({
    required this.id,
    required this.establishmentId,
    required this.establishmentName,
    this.photoUrl,
    this.logoUrl,
    required this.format,
    this.score = 0,
    this.promotionId,
    this.promotionName,
    this.promotionPhotoUrl,
  });

  /// ¿Es un anuncio de promoción específica?
  bool get isPromotionAd => promotionId != null;

  /// Título a mostrar: nombre de la promo si existe, si no el negocio.
  String get displayTitle => isPromotionAd
      ? (promotionName ?? establishmentName)
      : establishmentName;

  /// Imagen "hero": promo → foto de la promo; establecimiento → logo.
  String? get displayPhotoUrl => isPromotionAd
      ? (promotionPhotoUrl ?? photoUrl)
      : (logoUrl ?? photoUrl);

  factory AdDisplayModel.fromJson(Map<String, dynamic> json) {
    // Soporta tanto el resultado plano del RPC como el antiguo JOIN anidado
    final est = json['establishments'] as Map<String, dynamic>?;
    return AdDisplayModel(
      id:                json['id']               as String,
      establishmentId:   json['establishment_id'] as String,
      format:            json['format']           as String,
      establishmentName: (json['establishment_name']
                          ?? est?['name']
                          ?? 'Negocio')           as String,
      photoUrl:          (json['photo_url']
                          ?? est?['photo_url'])   as String?,
      logoUrl:           (json['logo_url']
                          ?? est?['logo_url'])    as String?,
      score:            (json['score']            as num?)?.toDouble() ?? 0,
      promotionId:       json['promotion_id']       as String?,
      promotionName:     json['promotion_name']     as String?,
      promotionPhotoUrl: json['promotion_photo_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id, establishmentId, establishmentName, photoUrl, logoUrl, format, score,
    promotionId, promotionName, promotionPhotoUrl,
  ];
}
