import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/admin_establishment_entry.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/characteristic_model.dart';
import '../../../data/models/membership_plan_model.dart';
// ignore: unused_import — usado implícitamente en createScheduled (inferred type)
import '../../../data/models/scheduled_notification_model.dart';
import '../../../data/repositories/ads_repository.dart';
import '../../../data/repositories/categories_repository.dart';
import '../../../data/repositories/membership_plans_repository.dart';
import '../../../data/repositories/notifications_repository.dart';
import 'superadmin_state.dart';

class SuperadminCubit extends Cubit<SuperadminState> {
  final MembershipPlansRepository _repo;
  final CategoriesRepository      _catRepo;
  final NotificationsRepository   _notifRepo;
  final AdsRepository             _adsRepo;

  SuperadminCubit({
    required MembershipPlansRepository repo,
    CategoriesRepository?    categoriesRepository,
    NotificationsRepository? notificationsRepository,
    AdsRepository?           adsRepository,
  })  : _repo      = repo,
        _catRepo   = categoriesRepository    ?? CategoriesRepository(),
        _notifRepo = notificationsRepository ?? NotificationsRepository(),
        _adsRepo   = adsRepository           ?? AdsRepository(),
        super(const SuperadminInitial());

  // ── Carga ─────────────────────────────────────────────────────────────────

  Future<void> load() async {
    emit(const SuperadminLoading());
    try {
      final results = await Future.wait([
        _repo.getPlans(),
        _repo.getBusinessOwnersForAdmin(),
        _catRepo.getCategories(),
        _catRepo.getCharacteristics(),
      ]);

      final plans    = results[0] as List<MembershipPlanModel>;
      final rawUsers = results[1] as List<Map<String, dynamic>>;
      final cats     = results[2] as List<CategoryModel>;
      final chars    = results[3] as List<CharacteristicModel>;

      final planMap = {for (final p in plans) p.id: p.name};
      final users   = rawUsers.map((u) {
        final planId   = (u['plan_id'] as int?) ?? plans.first.id;
        final planName = planMap[planId] ?? plans.first.name;
        final rawName  = u['full_name'] as String?;
        final display  = (rawName != null && rawName.isNotEmpty)
            ? rawName
            : 'Usuario ${(u['id'] as String).substring(0, 8)}';
        return AdminUserEntry(
          id:          u['id']    as String,
          displayName: display,
          email:       (u['email'] as String?) ?? '',
          planId:      planId,
          planName:    planName,
          estCount:    (u['est_count'] as int?) ?? 0,
        );
      }).toList();

      // Datos de notificaciones (silencioso si falla)
      List<dynamic> notifLogs      = [];
      List<dynamic> scheduled      = [];
      Map<String, int> deviceStats = {};
      List<Map<String, dynamic>> dailyStats = [];
      try {
        final notifResults = await Future.wait([
          _notifRepo.getLogs(),
          _notifRepo.getDeviceStats(),
          _notifRepo.getScheduled(),
          _notifRepo.getDailyStats(),
        ]);
        notifLogs   = notifResults[0] as List;
        deviceStats = notifResults[1] as Map<String, int>;
        scheduled   = notifResults[2] as List;
        dailyStats  = (notifResults[3] as List).cast<Map<String, dynamic>>();
      } catch (_) {}

      // Precios de publicidad + conteo total de usuarios (silencioso si falla)
      var adPricing     = <dynamic>[];
      var totalUserCount = 0;
      try {
        final adsResults = await Future.wait([
          _adsRepo.getPricing(),
          _adsRepo.getTotalUserCount(),
        ]);
        adPricing      = adsResults[0] as List;
        totalUserCount = adsResults[1] as int;
      } catch (_) {}

      // Precios de add-ons (silencioso si la tabla aún no existe en Supabase)
      var addonPricingList = <dynamic>[];
      try {
        addonPricingList = await _repo.getAddonPricing();
      } catch (_) {}

      emit(SuperadminLoaded(
        plans:                  plans,
        users:                  users,
        categories:             cats,
        characteristics:        chars,
        notificationLogs:       notifLogs.cast(),
        scheduledNotifications: scheduled.cast(),
        deviceStats:            deviceStats,
        dailyStats:             dailyStats,
        adPricing:              adPricing.cast(),
        totalUserCount:         totalUserCount,
        addonPricing:           addonPricingList.cast(),
      ));
    } catch (e) {
      emit(SuperadminError(e.toString()));
    }
  }

  // ── Planes ────────────────────────────────────────────────────────────────

  Future<void> updatePlan(MembershipPlanModel plan) async {
    final current = state;
    if (current is! SuperadminLoaded) return;
    try {
      await _repo.updatePlan(plan);
      emit(current.copyWith(
        plans: current.plans.map((p) => p.id == plan.id ? plan : p).toList(),
      ));
    } catch (_) {}
  }

  Future<void> assignPlan(String userId, int planId) async {
    final current = state;
    if (current is! SuperadminLoaded) return;
    try {
      await _repo.assignPlanToUser(userId, planId);
      final planName = current.plans
          .firstWhere((p) => p.id == planId, orElse: () => current.plans.first)
          .name;
      emit(current.copyWith(
        users: current.users
            .map((u) => u.id == userId
                ? u.copyWith(planId: planId, planName: planName)
                : u)
            .toList(),
      ));
    } catch (_) {}
  }

  // ── Notificaciones — broadcast ────────────────────────────────────────────

  /// Envía broadcast (o segmentado) y recarga historial. Lanza si falla.
  Future<({int sent, int failed})> sendBroadcast({
    required String title,
    required String body,
    required String sentBy,
    Map<String, dynamic> filters = const {},
  }) async {
    final result = await _notifRepo.sendBroadcast(
        title: title, body: body, sentBy: sentBy, filters: filters);
    final logs = await _notifRepo.getLogs();
    final current = state;
    if (current is SuperadminLoaded) {
      emit(current.copyWith(notificationLogs: logs));
    }
    return result;
  }

  /// Preview: cuántos dispositivos recibirán la notificación con estos filtros.
  Future<int> countRecipients(Map<String, dynamic> filters) =>
      _notifRepo.countRecipients(filters);

  // ── Notificaciones — programadas ──────────────────────────────────────────

  Future<void> createScheduled({
    required String title,
    required String body,
    required DateTime sendAt,
    String? recurrence,
    Map<String, dynamic> filters = const {},
    String? createdBy,
  }) async {
    final sched = await _notifRepo.createScheduled(
      title:      title,
      body:       body,
      sendAt:     sendAt,
      recurrence: recurrence,
      filters:    filters,
      createdBy:  createdBy,
    );
    final current = state;
    if (current is SuperadminLoaded) {
      final updated = [...current.scheduledNotifications, sched]
        ..sort((a, b) => a.sendAt.compareTo(b.sendAt));
      emit(current.copyWith(scheduledNotifications: updated));
    }
  }

  Future<void> cancelScheduled(String id) async {
    await _notifRepo.cancelScheduled(id);
    final current = state;
    if (current is SuperadminLoaded) {
      emit(current.copyWith(
        scheduledNotifications: current.scheduledNotifications
            .where((s) => s.id != id)
            .toList(),
      ));
    }
  }

  // ── CRUD Categorías ───────────────────────────────────────────────────────

  Future<void> createCategory({
    required String name,
    String? icon,
    String? parentId,
  }) async {
    final current = state;
    if (current is! SuperadminLoaded) return;
    final cat = await _catRepo.createCategory(
        name: name, icon: icon, parentId: parentId);
    final updated = [...current.categories, cat]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    emit(current.copyWith(categories: updated));
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    String? icon,
    String? parentId,
    bool    clearParent = false,
  }) async {
    final current = state;
    if (current is! SuperadminLoaded) return;
    final cat = await _catRepo.updateCategory(
        id: id, name: name, icon: icon,
        parentId: parentId, clearParent: clearParent);
    emit(current.copyWith(
      categories: current.categories.map((c) => c.id == id ? cat : c).toList(),
    ));
  }

  Future<void> deleteCategory(String id) async {
    final current = state;
    if (current is! SuperadminLoaded) return;
    await _catRepo.deleteCategory(id);
    emit(current.copyWith(
      categories: current.categories.where((c) => c.id != id).toList(),
    ));
  }

  // ── CRUD Características ──────────────────────────────────────────────────

  Future<void> createCharacteristic({required String name, String? icon}) async {
    final current = state;
    if (current is! SuperadminLoaded) return;
    final ch = await _catRepo.createCharacteristic(name: name, icon: icon);
    emit(current.copyWith(
      characteristics: [...current.characteristics, ch]
        ..sort((a, b) => a.name.compareTo(b.name)),
    ));
  }

  Future<void> updateCharacteristic({
    required String id,
    required String name,
    String? icon,
  }) async {
    final current = state;
    if (current is! SuperadminLoaded) return;
    final ch = await _catRepo.updateCharacteristic(id: id, name: name, icon: icon);
    emit(current.copyWith(
      characteristics: current.characteristics
          .map((c) => c.id == id ? ch : c)
          .toList(),
    ));
  }

  Future<void> deleteCharacteristic(String id) async {
    final current = state;
    if (current is! SuperadminLoaded) return;
    await _catRepo.deleteCharacteristic(id);
    emit(current.copyWith(
      characteristics: current.characteristics.where((c) => c.id != id).toList(),
    ));
  }

  // ── Publicidad — precios ──────────────────────────────────────────────────

  /// Actualiza el precio de un formato publicitario. Lanza si falla.
  Future<void> updateAdPricing({
    required int    id,
    required double priceMxn,
    required double minBudgetMxn,
  }) async {
    final current = state;
    if (current is! SuperadminLoaded) return;
    final updated = await _adsRepo.updatePricing(
      id: id, priceMxn: priceMxn, minBudgetMxn: minBudgetMxn,
    );
    emit(current.copyWith(
      adPricing: current.adPricing
          .map((p) => p.id == id ? updated : p)
          .toList(),
    ));
  }

  // ── Add-ons — precios ─────────────────────────────────────────────────────

  /// Actualiza el precio de un add-on. Lanza si falla.
  Future<void> updateAddonPricing({
    required int    id,
    required double priceMxn,
  }) async {
    final current = state;
    if (current is! SuperadminLoaded) return;
    final updated = await _repo.updateAddonPricing(id: id, priceMxn: priceMxn);
    emit(current.copyWith(
      addonPricing: current.addonPricing
          .map((a) => a.id == id ? updated : a)
          .toList(),
    ));
  }

  // ── Créditos publicitarios ────────────────────────────────────────────────

  Future<List<AdminEstablishmentEntry>> loadEstablishmentsForCredits() =>
      _adsRepo.getAllEstablishmentsForAdmin();

  Future<void> addCredit({
    required String establishmentId,
    required double amountMxn,
    required String description,
    required String addedBy,
  }) =>
      _adsRepo.addCredit(
        establishmentId: establishmentId,
        amountMxn:       amountMxn,
        description:     description,
        addedBy:         addedBy,
      );
}
