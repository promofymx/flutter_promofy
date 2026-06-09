import 'dart:async';
import '../../../main.dart';
import '../../models/loyalty_client_model.dart';
import '../../models/loyalty_program_model.dart';
import '../../models/stamp_card_model.dart';

class LoyaltyDatasource {
  // ── Dueño: programa de lealtad ────────────────────────────────────────────

  /// Obtiene el programa activo (o el más reciente) de un establecimiento.
  Future<LoyaltyProgramModel?> getActiveProgram({
    required String establishmentId,
    required String establishmentName,
    String? establishmentLogo,
  }) async {
    final rows = await supabase
        .from('loyalty_programs')
        .select()
        .eq('establishment_id', establishmentId)
        .order('created_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) return null;
    return LoyaltyProgramModel.fromJson(
      rows.first,
      establishmentName: establishmentName,
      establishmentLogo: establishmentLogo,
    );
  }

  /// Crea un nuevo programa de lealtad.
  Future<LoyaltyProgramModel> createProgram({
    required String   establishmentId,
    required String   establishmentName,
    String?           establishmentLogo,
    required int      visitsRequired,
    required String   rewardDescription,
    required DateTime startsAt,
    required DateTime endsAt,
    bool   onePerDay          = false,
    double minTicketMxn       = 0,
    int    minHoursBetween    = 0,
    int    stampValidityDays  = 0,
    int    rewardValidityDays = 0,
  }) async {
    final row = await supabase
        .from('loyalty_programs')
        .insert({
          'establishment_id':     establishmentId,
          'visits_required':      visitsRequired,
          'reward_description':   rewardDescription,
          'starts_at':            startsAt.toUtc().toIso8601String(),
          'ends_at':              endsAt.toUtc().toIso8601String(),
          'is_active':            true,
          'one_per_day':          onePerDay,
          'min_ticket_mxn':       minTicketMxn,
          'min_hours_between':    minHoursBetween,
          'stamp_validity_days':  stampValidityDays,
          'reward_validity_days': rewardValidityDays,
        })
        .select()
        .single();

    return LoyaltyProgramModel.fromJson(
      row,
      establishmentName: establishmentName,
      establishmentLogo: establishmentLogo,
    );
  }

  /// Desactiva un programa (is_active = false).
  Future<void> deactivateProgram(String programId) async {
    await supabase
        .from('loyalty_programs')
        .update({'is_active': false})
        .eq('id', programId);
  }

  // ── Dueño: escanear QR del cliente ────────────────────────────────────────

  /// RPC SECURITY DEFINER: el dueño registra una visita escaneando el QR
  /// del cliente. Devuelve el estado actualizado de la tarjeta.
  /// Además actualiza las estadísticas globales del cliente (fire-and-forget).
  Future<Map<String, dynamic>> recordVisit({
    required String programId,
    required String clientId,
    double? ticketAmount,
  }) async {
    final result = await supabase.rpc(
      'record_loyalty_visit',
      params: {
        'p_program_id': programId,
        'p_client_id':  clientId,
        if (ticketAmount != null) 'p_ticket_amount': ticketAmount,
      },
    );
    final data = result as Map<String, dynamic>;
    // Actualizar estadísticas globales del cliente (visitas anuales, racha)
    // Se ejecuta en segundo plano; el error no afecta el flujo principal.
    if (data['ok'] == true) {
      unawaited(
        supabase
            .rpc('update_user_visit_stats', params: {'p_user_id': clientId})
            .catchError((_) {}),
      );
    }
    return data;
  }

  /// RPC SECURITY DEFINER: el dueño confirma la entrega del premio.
  Future<Map<String, dynamic>> claimReward({
    required String programId,
    required String clientId,
  }) async {
    final result = await supabase.rpc(
      'claim_loyalty_reward',
      params: {
        'p_program_id': programId,
        'p_client_id':  clientId,
      },
    );
    return result as Map<String, dynamic>;
  }

  // ── Dueño: ver tarjetas de su establecimiento ─────────────────────────────

  /// Lista todas las tarjetas de clientes para un programa.
  Future<List<StampCardModel>> getCardsForProgram(String programId) async {
    final rows = await supabase
        .from('stamp_cards')
        .select('''
          *,
          loyalty_programs (
            visits_required,
            reward_description,
            ends_at,
            is_active,
            establishments ( id, name, logo_url )
          )
        ''')
        .eq('program_id', programId)
        .order('program_visits', ascending: false);

    return rows.map(StampCardModel.fromJson).toList();
  }

  // ── Dueño: clientes del programa (tablas de progreso + historial) ────────

  Future<LoyaltyClientsData> getClients(String programId) async {
    final result = await supabase.rpc(
      'get_loyalty_clients',
      params: {'p_program_id': programId},
    );
    return LoyaltyClientsData.fromJson(result as Map<String, dynamic>);
  }

  // ── Cliente: mis tarjetas ────────────────────────────────────────────────

  /// Todas las tarjetas del usuario autenticado, con info del programa
  /// y del establecimiento (join).
  Future<List<StampCardModel>> getMyCards(String userId) async {
    final rows = await supabase
        .from('stamp_cards')
        .select('''
          *,
          loyalty_programs (
            visits_required,
            reward_description,
            ends_at,
            is_active,
            establishments ( id, name, logo_url )
          )
        ''')
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return rows.map(StampCardModel.fromJson).toList();
  }
}
