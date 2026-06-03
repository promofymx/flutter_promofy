import 'package:equatable/equatable.dart';

class EstablishmentPhotoModel extends Equatable {
  final String id;
  final String establishmentId;
  final String category; // 'establishment' | 'children_area' | 'menu'
  final String url;
  final int    sortOrder;

  const EstablishmentPhotoModel({
    required this.id,
    required this.establishmentId,
    required this.category,
    required this.url,
    this.sortOrder = 0,
  });

  factory EstablishmentPhotoModel.fromJson(Map<String, dynamic> json) {
    return EstablishmentPhotoModel(
      id:              json['id']               as String,
      establishmentId: json['establishment_id'] as String,
      category:        json['category']         as String,
      url:             json['url']              as String,
      sortOrder:       (json['sort_order'] as int?) ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, url, category];
}
