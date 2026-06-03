import 'package:equatable/equatable.dart';

class CharacteristicModel extends Equatable {
  final String id;
  final String name;
  final String? icon;

  const CharacteristicModel({
    required this.id,
    required this.name,
    this.icon,
  });

  factory CharacteristicModel.fromJson(Map<String, dynamic> json) {
    return CharacteristicModel(
      // id puede llegar como int (tabla usa integer) — convertimos a String
      id:   json['id'].toString(),
      name: json['name'] as String,
      icon: json['icon'] as String?,
    );
  }

  CharacteristicModel copyWith({String? name, String? icon}) =>
      CharacteristicModel(
        id:   id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
      );

  @override
  List<Object?> get props => [id, name, icon];
}
