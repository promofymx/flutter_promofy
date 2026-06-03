import 'package:equatable/equatable.dart';

// ─── Staff de un establecimiento ─────────────────────────────────────────────

class StaffMemberModel extends Equatable {
  final String            id;
  final String            userId;
  final String            displayName;
  final String            email;
  final String            role;         // 'manager' | 'cashier' | 'custom'
  final Map<String, bool> permissions;
  final DateTime          createdAt;

  const StaffMemberModel({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.email,
    required this.role,
    required this.permissions,
    required this.createdAt,
  });

  String get roleLabel {
    switch (role) {
      case 'manager': return 'Gerente';
      case 'cashier': return 'Cajero';
      default:        return 'Personalizado';
    }
  }

  factory StaffMemberModel.fromJson(Map<String, dynamic> j) {
    final rawPerms = j['permissions'] as Map<String, dynamic>? ?? {};
    return StaffMemberModel(
      id:          j['id']        as String,
      userId:      j['user_id']   as String,
      displayName: (j['full_name'] as String?)?.isNotEmpty == true
          ? j['full_name'] as String
          : (j['email'] as String? ?? '').split('@').first,
      email:       j['email']     as String? ?? '',
      role:        j['role']      as String,
      permissions: rawPerms.map((k, v) => MapEntry(k, v == true)),
      createdAt:   DateTime.parse(j['created_at'] as String).toLocal(),
    );
  }

  @override
  List<Object?> get props => [id, userId, role, permissions];
}

// ─── Entrada de usuario para panel superadmin ─────────────────────────────────

class AdminAllUserEntry extends Equatable {
  final String   id;
  final String   displayName;
  final String   email;
  final String   role;       // 'user' | 'staff' | 'business_owner' | 'admin'
  final bool     isActive;
  final bool     isBanned;
  final DateTime createdAt;

  const AdminAllUserEntry({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    required this.isActive,
    required this.isBanned,
    required this.createdAt,
  });

  bool   get isBlocked  => !isActive || isBanned;
  String get roleLabel  {
    switch (role) {
      case 'business_owner': return 'Dueño';
      case 'admin':          return 'Admin';
      case 'staff':          return 'Staff';
      default:               return 'Usuario';
    }
  }

  AdminAllUserEntry copyWith({bool? isActive, bool? isBanned}) =>
      AdminAllUserEntry(
        id:          id,
        displayName: displayName,
        email:       email,
        role:        role,
        isActive:    isActive  ?? this.isActive,
        isBanned:    isBanned  ?? this.isBanned,
        createdAt:   createdAt,
      );

  factory AdminAllUserEntry.fromJson(Map<String, dynamic> j) =>
      AdminAllUserEntry(
        id:          j['id']        as String,
        displayName: (j['full_name'] as String?)?.isNotEmpty == true
            ? j['full_name'] as String
            : (j['email'] as String? ?? '').split('@').first,
        email:       j['email']     as String? ?? '',
        role:        j['role']      as String?  ?? 'user',
        isActive:    (j['is_active'] as bool?)  ?? true,
        isBanned:    (j['is_banned'] as bool?)  ?? false,
        createdAt:   DateTime.parse(j['created_at'] as String).toLocal(),
      );

  @override
  List<Object?> get props => [id, role, isActive, isBanned];
}
