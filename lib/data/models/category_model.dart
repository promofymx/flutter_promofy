import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String? nameEn;
  final String? nameDe;
  final String? parentId;
  final String? icon;
  final int sortOrder;

  const CategoryModel({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameDe,
    this.parentId,
    this.icon,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      // id y parent_id pueden llegar como int (tabla usa integer)
      id:        json['id'].toString(),
      name:      json['name']      as String,
      nameEn:    json['name_en']   as String?,
      nameDe:    json['name_de']   as String?,
      parentId:  json['parent_id']?.toString(),
      icon:      json['icon']      as String?,
      sortOrder: (json['sort_order'] as int?) ?? 0,
    );
  }

  /// Nombre en el idioma [langCode] ('en'/'de'); fallback a español.
  String localizedName(String langCode) {
    switch (langCode) {
      case 'en': return (nameEn?.isNotEmpty ?? false) ? nameEn! : name;
      case 'de': return (nameDe?.isNotEmpty ?? false) ? nameDe! : name;
      default:   return name;
    }
  }

  CategoryModel copyWith({
    String? name,
    String? icon,
    int?    sortOrder,
  }) =>
      CategoryModel(
        id:        id,
        name:      name      ?? this.name,
        nameEn:    nameEn,
        nameDe:    nameDe,
        parentId:  parentId,
        icon:      icon      ?? this.icon,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  @override
  List<Object?> get props => [id, name, nameEn, nameDe, parentId, icon, sortOrder];
}
