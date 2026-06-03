import 'package:flutter/foundation.dart';
import '../../main.dart';
import '../models/staff_member_model.dart';

class StaffRepository {
  // ── Invitaciones ───────────────────────────────────────────────────────────

  /// Genera un código de 6 caracteres y lo registra en staff_invitations.
  Future<String> createInvitation({
    required String            establishmentId,
    required String            role,
    Map<String, bool>          permissions = const {},
  }) async {
    final result = await supabase.rpc('create_staff_invitation', params: {
      'p_establishment_id': establishmentId,
      'p_role':             role,
      'p_permissions':      permissions,
    });
    return result as String;
  }

  /// El empleado ingresa el código; devuelve {success, establishment_name, role}
  /// o {success: false, error: '...'}.
  Future<Map<String, dynamic>> acceptInvitation(String code) async {
    final result = await supabase.rpc('accept_staff_invitation', params: {
      'p_code': code,
    });
    return (result as Map<String, dynamic>);
  }

  // ── Staff del establecimiento ──────────────────────────────────────────────

  Future<List<StaffMemberModel>> getStaff(String establishmentId) async {
    final rows = await supabase.rpc('get_establishment_staff', params: {
      'p_establishment_id': establishmentId,
    });
    return (rows as List)
        .map((e) => StaffMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> removeStaff(String establishmentId, String userId) async {
    await supabase.rpc('remove_staff_member', params: {
      'p_establishment_id': establishmentId,
      'p_user_id':          userId,
    });
  }

  // ── Staff: mis empleos ────────────────────────────────────────────────────

  /// Devuelve los establecimientos donde el usuario autenticado es staff.
  /// Cada entrada tiene: { role, permissions, establishments: {id, name} }
  Future<List<Map<String, dynamic>>> getMyStaffMemberships() async {
    final uid = supabase.auth.currentUser?.id;
    debugPrint('[StaffRepo] uid=$uid');
    if (uid == null) return [];

    // Paso 1: filas propias del empleado
    final rows = await supabase
        .from('establishment_staff')
        .select('establishment_id, role, permissions')
        .eq('user_id', uid);

    debugPrint('[StaffRepo] establishment_staff rows=${rows.length}');
    if (rows.isEmpty) return [];

    // Paso 2: nombre de cada establecimiento por separado (evita inFilter con UUIDs)
    final result = <Map<String, dynamic>>[];
    for (final row in rows) {
      final estId = row['establishment_id'] as String;
      Map<String, dynamic>? estInfo;
      try {
        estInfo = await supabase
            .from('establishments')
            .select('id, name')
            .eq('id', estId)
            .maybeSingle();
        debugPrint('[StaffRepo] est=$estId name=${estInfo?['name']}');
      } catch (e) {
        debugPrint('[StaffRepo] establishments query error: $e');
      }
      result.add({
        'establishment_id': estId,
        'role':             row['role'],
        'permissions':      row['permissions'],
        'establishments':   estInfo ?? {'id': estId, 'name': '—'},
      });
    }
    return result;
  }

  // ── Superadmin: todos los usuarios ────────────────────────────────────────

  Future<List<AdminAllUserEntry>> getAllUsers({
    int limit  = 200,
    int offset = 0,
  }) async {
    final rows = await supabase.rpc('get_all_users_for_admin', params: {
      'p_limit':  limit,
      'p_offset': offset,
    });
    return (rows as List)
        .map((e) => AdminAllUserEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> setUserActive(String userId, {required bool active}) async {
    await supabase.rpc('set_user_active', params: {
      'p_user_id': userId,
      'p_active':  active,
    });
  }
}
