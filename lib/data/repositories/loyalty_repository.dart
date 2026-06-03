import '../datasources/supabase/loyalty_datasource.dart';
import '../models/loyalty_client_model.dart';
import '../models/loyalty_program_model.dart';
import '../models/stamp_card_model.dart';

class LoyaltyRepository {
  final LoyaltyDatasource _datasource;

  LoyaltyRepository({LoyaltyDatasource? datasource})
      : _datasource = datasource ?? LoyaltyDatasource();

  // ── Dueño ─────────────────────────────────────────────────────────────────

  Future<LoyaltyProgramModel?> getActiveProgram({
    required String establishmentId,
    required String establishmentName,
    String? establishmentLogo,
  }) =>
      _datasource.getActiveProgram(
        establishmentId:   establishmentId,
        establishmentName: establishmentName,
        establishmentLogo: establishmentLogo,
      );

  Future<LoyaltyProgramModel> createProgram({
    required String   establishmentId,
    required String   establishmentName,
    String?           establishmentLogo,
    required int      visitsRequired,
    required String   rewardDescription,
    required DateTime startsAt,
    required DateTime endsAt,
  }) =>
      _datasource.createProgram(
        establishmentId:   establishmentId,
        establishmentName: establishmentName,
        establishmentLogo: establishmentLogo,
        visitsRequired:    visitsRequired,
        rewardDescription: rewardDescription,
        startsAt:          startsAt,
        endsAt:            endsAt,
      );

  Future<void> deactivateProgram(String programId) =>
      _datasource.deactivateProgram(programId);

  Future<Map<String, dynamic>> recordVisit({
    required String programId,
    required String clientId,
  }) =>
      _datasource.recordVisit(
        programId: programId,
        clientId:  clientId,
      );

  Future<Map<String, dynamic>> claimReward({
    required String programId,
    required String clientId,
  }) =>
      _datasource.claimReward(
        programId: programId,
        clientId:  clientId,
      );

  Future<List<StampCardModel>> getCardsForProgram(String programId) =>
      _datasource.getCardsForProgram(programId);

  Future<LoyaltyClientsData> getClients(String programId) =>
      _datasource.getClients(programId);

  // ── Cliente ────────────────────────────────────────────────────────────────

  Future<List<StampCardModel>> getMyCards(String userId) =>
      _datasource.getMyCards(userId);
}
