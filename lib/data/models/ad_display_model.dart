import 'package:equatable/equatable.dart';

/// Modelo ligero para renderizar un anuncio al usuario final.
/// Se obtiene con un JOIN entre ad_campaigns y establishments.
class AdDisplayModel extends Equatable {
  final String  id;               // campaign id
  final String  establishmentId;
  final String  establishmentName;
  final String? photoUrl;
  final String  format; // splash | featured_list | banner

  const AdDisplayModel({
    required this.id,
    required this.establishmentId,
    required this.establishmentName,
    this.photoUrl,
    required this.format,
  });

  factory AdDisplayModel.fromJson(Map<String, dynamic> json) {
    final est = json['establishments'] as Map<String, dynamic>?;
    return AdDisplayModel(
      id:                json['id']               as String,
      establishmentId:   json['establishment_id'] as String,
      format:            json['format']           as String,
      establishmentName: est?['name']             as String? ?? 'Negocio',
      photoUrl:          est?['photo_url']        as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, establishmentId, establishmentName, photoUrl, format];
}
