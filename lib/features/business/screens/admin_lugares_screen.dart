import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/supabase/business_datasource.dart';
import '../../../data/models/characteristic_model.dart';
import '../../../data/models/establishment_model.dart';
import '../../../data/models/promotion_model.dart';
import '../../../data/repositories/business_repository.dart';
import '../../../main.dart' show supabase;
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../cubit/business_cubit.dart';
import '../widgets/photos_section.dart';
import 'promo_form_screen.dart';
import 'register_business_screen.dart';

/// Panel de admin para gestionar Lugares (Establecimientos + Promociones).
class AdminLugaresScreen extends StatefulWidget {
  const AdminLugaresScreen({super.key});

  @override
  State<AdminLugaresScreen> createState() => _AdminLugaresScreenState();
}

class _AdminLugaresScreenState extends State<AdminLugaresScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _ds = BusinessDatasource();

  // ── Estado: Establecimientos ──────────────────────────────────────────────
  bool   _loadingEsts = true;
  String _queryEsts   = '';
  String? _errorEsts;
  List<EstablishmentModel> _establishments = [];

  // ── Estado: Promociones ───────────────────────────────────────────────────
  bool   _loadingPromos   = false;
  EstablishmentModel? _selectedEst;
  List<PromotionModel> _promos = [];

  String get _adminId {
    final auth = context.read<AuthBloc>().state;
    return auth is AuthAuthenticated ? auth.profile.id : '';
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadEstablishments();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // ── Carga de establecimientos ─────────────────────────────────────────────

  Future<void> _loadEstablishments() async {
    setState(() { _loadingEsts = true; _errorEsts = null; });
    try {
      final list = await _ds.getMyEstablishments(_adminId);
      if (mounted) setState(() { _establishments = list; _loadingEsts = false; });
    } catch (e) {
      if (mounted) setState(() { _errorEsts = e.toString(); _loadingEsts = false; });
    }
  }

  // ── Carga de promociones del establecimiento seleccionado ─────────────────

  Future<void> _loadPromos(EstablishmentModel est) async {
    setState(() { _loadingPromos = true; _selectedEst = est; _promos = []; });
    try {
      final repo  = BusinessRepository();
      final items = await repo.getOwnerPromosByEstablishment(
        establishmentId:   est.id,
        establishmentName: est.name,
        establishmentLogo: est.logoUrl,
      );
      if (mounted) setState(() { _promos = items; _loadingPromos = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingPromos = false);
    }
  }

  // ── Fetch características para pre-fill al editar ─────────────────────────

  Future<EstablishmentModel> _withCharacteristics(EstablishmentModel est) async {
    try {
      final rows = await supabase
          .from('establishment_characteristics')
          .select('characteristic_id')
          .eq('establishment_id', est.id);
      final chars = (rows as List).map((r) => CharacteristicModel(
            id:   r['characteristic_id'].toString(),
            name: '',
          )).toList();
      return est.copyWith(characteristics: chars);
    } catch (_) {
      return est;
    }
  }

  // ── Navegación: crear / editar establecimiento ────────────────────────────

  void _openCreate() {
    final adminId = _adminId;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => BusinessCubit(
            repository: BusinessRepository(), userId: adminId),
        child: const RegisterBusinessScreen(),
      ),
    )).then((_) => _loadEstablishments());
  }

  Future<void> _openEdit(EstablishmentModel est) async {
    final adminId   = _adminId;
    final estFull   = await _withCharacteristics(est);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => BusinessCubit(
            repository: BusinessRepository(), userId: adminId),
        child: RegisterBusinessScreen(establishment: estFull),
      ),
    )).then((_) => _loadEstablishments());
  }

  // ── Navegación: fotos ─────────────────────────────────────────────────────

  void _openPhotos(EstablishmentModel est) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Fotos — ${est.name}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: PhotosSection(establishment: est),
        ),
      ),
    ));
  }

  // ── Navegación: crear/editar promoción ───────────────────────────────────

  void _openPromoForm({PromotionModel? existing, required EstablishmentModel est}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PromoFormScreen(
        existing:          existing,
        establishmentName: est.name,
        establishmentId:   est.id,
        staffUserId:       _adminId,
      ),
    )).then((_) => _loadPromos(est));
  }

  // ── Eliminar establecimiento ──────────────────────────────────────────────

  Future<void> _deleteEst(EstablishmentModel est) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar lugar'),
        content: Text(
            '¿Eliminar "${est.name}"?\nTambién eliminará sus promociones.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await _ds.deleteEstablishment(est.id);
      setState(() {
        _establishments =
            _establishments.where((e) => e.id != est.id).toList();
        if (_selectedEst?.id == est.id) {
          _selectedEst = null;
          _promos = [];
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Admin Lugares',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon:    const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: _loadEstablishments,
          ),
        ],
        bottom: TabBar(
          controller:           _tab,
          labelColor:           AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor:       AppColors.primary,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.store_outlined, size: 18), text: 'Establecimientos'),
            Tab(icon: Icon(Icons.local_offer_outlined, size: 18), text: 'Promociones'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _EstablishmentsTab(
            loading:        _loadingEsts,
            error:          _errorEsts,
            establishments: _establishments,
            query:          _queryEsts,
            onQueryChanged: (v) => setState(() => _queryEsts = v),
            onCreate:       _openCreate,
            onEdit:         _openEdit,
            onPhotos:       _openPhotos,
            onDelete:       _deleteEst,
            onManagePromos: (est) {
              setState(() => _selectedEst = est);
              _tab.animateTo(1);
              _loadPromos(est);
            },
          ),
          _PromosTab(
            establishments: _establishments,
            selectedEst:    _selectedEst,
            promos:         _promos,
            loading:        _loadingPromos,
            onSelectEst:    _loadPromos,
            onCreate:       () {
              if (_selectedEst != null) {
                _openPromoForm(est: _selectedEst!);
              }
            },
            onEdit: (promo) {
              if (_selectedEst != null) {
                _openPromoForm(existing: promo, est: _selectedEst!);
              }
            },
          ),
        ],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tab,
        builder: (_, __) => _tab.index == 0
            ? FloatingActionButton.extended(
                onPressed:       _openCreate,
                icon:            const Icon(Icons.add_business_rounded),
                label:           const Text('Agregar lugar'),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Tab 1 — Establecimientos
// ═══════════════════════════════════════════════════════════════════════════════

class _EstablishmentsTab extends StatelessWidget {
  final bool                     loading;
  final String?                  error;
  final List<EstablishmentModel> establishments;
  final String                   query;
  final void Function(String)    onQueryChanged;
  final VoidCallback             onCreate;
  final void Function(EstablishmentModel) onEdit;
  final void Function(EstablishmentModel) onPhotos;
  final void Function(EstablishmentModel) onDelete;
  final void Function(EstablishmentModel) onManagePromos;

  const _EstablishmentsTab({
    required this.loading,
    required this.error,
    required this.establishments,
    required this.query,
    required this.onQueryChanged,
    required this.onCreate,
    required this.onEdit,
    required this.onPhotos,
    required this.onDelete,
    required this.onManagePromos,
  });

  List<EstablishmentModel> get _filtered {
    if (query.isEmpty) return establishments;
    final q = query.toLowerCase();
    return establishments
        .where((e) =>
            e.name.toLowerCase().contains(q) ||
            (e.address?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Column(
      children: [
        // Búsqueda
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: TextField(
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText:   'Buscar…',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon:      const Icon(Icons.clear, size: 18),
                      onPressed: () => onQueryChanged(''),
                    )
                  : null,
              filled:         true,
              fillColor:      Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${filtered.length} lugar${filtered.length != 1 ? "es" : ""}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        ),
        // Lista
        Expanded(child: _buildBody(filtered)),
      ],
    );
  }

  Widget _buildBody(List<EstablishmentModel> filtered) {
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (error != null) {
      return Center(
          child: Text(error!, style: const TextStyle(color: Colors.red)));
    }
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              query.isEmpty
                  ? 'Aún no hay lugares. Toca + para agregar uno.'
                  : 'Sin resultados.',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color:     AppColors.primary,
      onRefresh: () async {},
      child: ListView.separated(
        padding:          const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount:        filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder:      (_, i) => _EstRow(
          est:           filtered[i],
          onEdit:        () => onEdit(filtered[i]),
          onPhotos:      () => onPhotos(filtered[i]),
          onDelete:      () => onDelete(filtered[i]),
          onManagePromos: () => onManagePromos(filtered[i]),
        ),
      ),
    );
  }
}

class _EstRow extends StatelessWidget {
  final EstablishmentModel est;
  final VoidCallback       onEdit;
  final VoidCallback       onPhotos;
  final VoidCallback       onDelete;
  final VoidCallback       onManagePromos;

  const _EstRow({
    required this.est,
    required this.onEdit,
    required this.onPhotos,
    required this.onDelete,
    required this.onManagePromos,
  });

  @override
  Widget build(BuildContext context) {
    final initials = est.name.trim().split(' ')
        .take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();

    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withAlpha(10),
              blurRadius: 6,
              offset:     const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Fila principal
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Row(
              children: [
                // Logo / inicial
                Container(
                  width:  50,
                  height: 50,
                  decoration: BoxDecoration(
                    color:        AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: est.logoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(est.logoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _InitialsBox(initials: initials)),
                        )
                      : _InitialsBox(initials: initials),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(est.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize:   14,
                              fontWeight: FontWeight.bold,
                              color:      AppColors.textDark)),
                      if (est.address?.isNotEmpty ?? false)
                        Text(est.address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                color:    Colors.grey.shade500)),
                    ],
                  ),
                ),
                // Menú contextual
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
                  onSelected: (val) {
                    if (val == 'edit')   onEdit();
                    if (val == 'photos') onPhotos();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Editar info'),
                        ])),
                    PopupMenuItem(value: 'photos',
                        child: Row(children: [
                          Icon(Icons.photo_library_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Gestionar fotos'),
                        ])),
                    PopupMenuItem(value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline, size: 18,
                              color: Colors.red),
                          SizedBox(width: 10),
                          Text('Eliminar',
                              style: TextStyle(color: Colors.red)),
                        ])),
                  ],
                ),
              ],
            ),
          ),
          // Botón de acceso rápido a promociones
          InkWell(
            onTap:        onManagePromos,
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(14)),
            child: Container(
              width:  double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color:        AppColors.primary.withAlpha(12),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  const Text('Gestionar promociones',
                      style: TextStyle(
                          fontSize:   12,
                          color:      AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsBox extends StatelessWidget {
  final String initials;
  const _InitialsBox({required this.initials});
  @override
  Widget build(BuildContext context) => Center(
        child: Text(initials,
            style: const TextStyle(
                fontSize:   18,
                fontWeight: FontWeight.bold,
                color:      AppColors.primary)),
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// Tab 2 — Promociones
// ═══════════════════════════════════════════════════════════════════════════════

class _PromosTab extends StatelessWidget {
  final List<EstablishmentModel> establishments;
  final EstablishmentModel?      selectedEst;
  final List<PromotionModel>     promos;
  final bool                     loading;
  final void Function(EstablishmentModel) onSelectEst;
  final VoidCallback             onCreate;
  final void Function(PromotionModel)     onEdit;

  const _PromosTab({
    required this.establishments,
    required this.selectedEst,
    required this.promos,
    required this.loading,
    required this.onSelectEst,
    required this.onCreate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de establecimiento
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: establishments.isEmpty
              ? Text('Primero crea un lugar en la pestaña Establecimientos.',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade500))
              : DropdownButtonFormField<EstablishmentModel>(
                  value:      selectedEst,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText:      'Selecciona un lugar',
                    prefixIcon:     const Icon(Icons.store_outlined, size: 20),
                    filled:         true,
                    fillColor:      Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  items: establishments
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.name,
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (e) { if (e != null) onSelectEst(e); },
                ),
        ),
        const SizedBox(height: 12),

        if (selectedEst != null) ...[
          // Botón crear promo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCreate,
                icon:  const Icon(Icons.add_rounded, size: 18),
                label: const Text('Nueva promoción'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Lista de promos
        Expanded(child: _buildPromoList()),
      ],
    );
  }

  Widget _buildPromoList() {
    if (selectedEst == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined,
                size: 56, color: Colors.grey.shade200),
            const SizedBox(height: 12),
            Text('Elige un lugar para ver sus promociones.',
                style: TextStyle(color: Colors.grey.shade400)),
          ],
        ),
      );
    }
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (promos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined,
                size: 48, color: Colors.grey.shade200),
            const SizedBox(height: 10),
            Text('Sin promociones. Toca "Nueva promoción".',
                style: TextStyle(color: Colors.grey.shade400),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.separated(
      padding:          const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount:        promos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder:      (_, i) => _PromoRow(
        promo:  promos[i],
        onEdit: () => onEdit(promos[i]),
      ),
    );
  }
}

class _PromoRow extends StatelessWidget {
  final PromotionModel promo;
  final VoidCallback   onEdit;

  const _PromoRow({required this.promo, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withAlpha(8),
              blurRadius: 4,
              offset:     const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          // Estado
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: promo.isCurrentlyActive ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promo.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize:   13,
                        fontWeight: FontWeight.w600,
                        color:      AppColors.textDark)),
                Text(
                  promo.isCurrentlyActive ? 'Activa' : 'Inactiva',
                  style: TextStyle(
                      fontSize: 11,
                      color: promo.isCurrentlyActive
                          ? Colors.green.shade700
                          : Colors.grey.shade500),
                ),
              ],
            ),
          ),
          IconButton(
            icon:      const Icon(Icons.edit_outlined, size: 18),
            color:     AppColors.primary,
            tooltip:   'Editar',
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
