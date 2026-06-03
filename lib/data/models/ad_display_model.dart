import 'package:equatable/equatable.dart';

/// Modelo ligero para renderizar un anuncio al usuario final.
/// Se obtiene via RPC get_ads_for_user (campos planos).
class AdDisplayModel extends Equatable {
  final String  id;               // campaign id
  final String  establishmentId;
  final String  establishmentName;
  final String? photoUrl;
  final String  format;           // splash | featured_list | banner
  final double  score;            // relevance score 0–100

  const AdDisplayModel({
    required this.id,
    required this.establishmentId,
    required this.establishmentName,
    this.photoUrl,
    required this.format,
    this.score = 0,
  });

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
      score:            (json['score']            as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [id, establishmentId, establishmentName, photoUrl, format, score];
}
