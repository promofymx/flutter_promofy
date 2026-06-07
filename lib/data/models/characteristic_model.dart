import 'package:equatable/equatable.dart';

class CharacteristicModel extends Equatable {
  final String id;
  final String name;
  final String? nameEn;
  final String? nameDe;
  final String? icon;

  const CharacteristicModel({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameDe,
    this.icon,
  });

  factory CharacteristicModel.fromJson(Map<String, dynamic> json) {
    return CharacteristicModel(
      // id puede llegar como int (tabla usa integer) — convertimos a String
      id:   json['id'].toString(),
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      nameDe: json['name_de'] as String?,
      icon: json['icon'] as String?,
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

  CharacteristicModel copyWith({String? name, String? icon}) =>
      CharacteristicModel(
        id:   id,
        name: name ?? this.name,
        nameEn: nameEn,
        nameDe: nameDe,
        icon: icon ?? this.icon,
      );

  @override
  List<Object?> get props => [id, name, nameEn, nameDe, icon];
}
