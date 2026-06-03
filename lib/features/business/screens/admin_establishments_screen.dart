import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/supabase/business_datasource.dart';
import '../../../data/models/establishment_model.dart';
import '../../../data/repositories/business_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../cubit/business_cubit.dart';
import 'register_business_screen.dart';

/// Panel de gestión de establecimientos para el admin.
/// Muestra todos los negocios creados con owner_id = adminId
/// (marcados automáticamente como is_admin_managed = true por trigger SQL).
class AdminEstablishmentsScreen extends StatefulWidget {
  const AdminEstablishmentsScreen({super.key});

  @override
  State<AdminEstablishmentsScreen> createState() =>
      _AdminEstablishmentsScreenState();
}

class _AdminEstablishmentsScreenState
    extends State<AdminEstablishmentsScreen> {
  final _ds = BusinessDatasource();

  bool   _loading = true;
  String _query   = '';
  String? _error;
  List<EstablishmentModel> _establishments = [];

  String get _adminId {
    final auth = context.read<AuthBloc>().state;
    return auth is AuthAuthenticated ? auth.profile.id : '';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _ds.getMyEstablishments(_adminId);
      if (mounted) setState(() { _establishments = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── Crear / editar ────────────────────────────────────────────────────────

  void _openCreate() {
    final adminId = _adminId;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => BusinessCubit(
            repository: BusinessRepository(),
            userId:     adminId,
          ),
          child: const RegisterBusinessScreen(),
        ),
      ),
    ).then((_) => _load());
  }

  void _openEdit(EstablishmentModel est) {
    final adminId = _adminId;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => BusinessCubit(
            repository: BusinessRepository(),
            userId:     adminId,
          ),
          child: RegisterBusinessScreen(establishment: est),
        ),
      ),
    ).then((_) => _load());
  }

  // ── Eliminar ──────────────────────────────────────────────────────────────

  Future<void> _delete(EstablishmentModel est) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar restaurante'),
        content: Text(
          '¿Eliminar "${est.name}"?\n'
          'Esto también eliminará sus promociones y datos asociados.',
        ),
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
        _establishments = _establishments.where((e) => e.id != est.id).toList();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('"${est.name}" eliminado.'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  List<EstablishmentModel> get _filtered {
    if (_query.isEmpty) return _establishments;
    final q = _query.toLowerCase();
    return _establishments
        .where((e) =>
            e.name.toLowerCase().contains(q) ||
            (e.address?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Restaurantes Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon:    const Icon(Icons.refresh_rounded),
              tooltip: 'Actualizar',
              onPressed: _load,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon:    const Icon(Icons.add_business_rounded),
        label:   const Text('Agregar restaurante'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── Barra de búsqueda ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText:   'Buscar por nombre o dirección…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon:      const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _query = ''),
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

          // ── Contador ───────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _loading
                    ? 'Cargando…'
                    : '${filtered.length} establecimiento${filtered.length != 1 ? "s" : ""}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
          ),

          // ── Cuerpo ─────────────────────────────────────────────────────
          Expanded(child: _buildBody(filtered)),
        ],
      ),
    );
  }

  Widget _buildBody(List<EstablishmentModel> filtered) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _load,
              icon:  const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              _query.isEmpty
                  ? 'Aún no hay restaurantes gestionados por Admin.'
                  : 'Sin resultados para "$_query".',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            if (_query.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openCreate,
                icon:  const Icon(Icons.add_business_rounded),
                label: const Text('Agregar primero'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      color:     AppColors.primary,
      onRefresh: _load,
      child: ListView.separated(
        padding:          const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount:        filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder:      (_, i) => _EstablishmentRow(
          est:      filtered[i],
          onEdit:   () => _openEdit(filtered[i]),
          onDelete: () => _delete(filtered[i]),
        ),
      ),
    );
  }
}

// ─── Fila de establecimiento ──────────────────────────────────────────────────

class _EstablishmentRow extends StatelessWidget {
  final EstablishmentModel est;
  final VoidCallback       onEdit;
  final VoidCallback       onDelete;

  const _EstablishmentRow({
    required this.est,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          // Logo / inicial
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14)),
            child: est.logoUrl != null
                ? Image.network(
                    est.logoUrl!,
                    width:  72,
                    height: 72,
                    fit:    BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _Initials(name: est.name),
                  )
                : _Initials(name: est.name),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    est.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.bold,
                      color:      AppColors.textDark,
                    ),
                  ),
                  if (est.address != null && est.address!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      est.address!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                  if (est.phone != null && est.phone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      est.phone!,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Acciones
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon:      const Icon(Icons.edit_outlined, size: 20),
                color:     AppColors.primary,
                tooltip:   'Editar',
                onPressed: onEdit,
              ),
              IconButton(
                icon:      const Icon(Icons.delete_outline, size: 20),
                color:     Colors.red.shade300,
                tooltip:   'Eliminar',
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String name;
  const _Initials({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Container(
      width:  72,
      height: 72,
      color:  AppColors.primary.withAlpha(20),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize:   22,
          fontWeight: FontWeight.bold,
          color:      AppColors.primary,
        ),
      ),
    );
  }
}
