import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/lugares_cubit.dart';
import '../cubit/lugares_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/establishment_model.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';

class LugaresScreen extends StatefulWidget {
  const LugaresScreen({super.key});

  @override
  State<LugaresScreen> createState() => _LugaresScreenState();
}

class _LugaresScreenState extends State<LugaresScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    context.read<LugaresCubit>().load();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent * 0.9) {
      context.read<LugaresCubit>().loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) context.read<LugaresCubit>().search(value.trim());
    });
  }

  // ── Bottom sheet de filtros avanzados ──────────────────────────────────────

  void _showAdvancedFilters(LugaresLoaded state) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => _LugaresFilterSheet(
        state:   state,
        onApply: (categoryId, charIds, dayOfWeek, paymentMethod) {
          context.read<LugaresCubit>().applyAdvancedFilters(
            categoryId:        categoryId,
            characteristicIds: charIds,
            dayOfWeek:         dayOfWeek,
            paymentMethod:     paymentMethod,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userId    = authState is AuthAuthenticated ? authState.user.id : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation:       0,
        leadingWidth:    52,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
        title: TextField(
          controller:      _searchController,
          onChanged:       _onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText:  'Buscar negocio...',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search,
                color: Colors.grey.shade400, size: 18),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close,
                        size: 16, color: Colors.grey.shade500),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            filled:      true,
            fillColor:   Colors.grey.shade50,
            isDense:     true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:   BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:   BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Barra de chips ─────────────────────────────────────────────────
          BlocBuilder<LugaresCubit, LugaresState>(
            buildWhen: (prev, next) {
              if (prev.runtimeType != next.runtimeType) return true;
              if (prev is LugaresLoaded && next is LugaresLoaded) {
                return prev.flashOnly              != next.flashOnly       ||
                       prev.openNow               != next.openNow         ||
                       prev.favoritesOnly         != next.favoritesOnly   ||
                       prev.advancedFilterCount   != next.advancedFilterCount;
              }
              return false;
            },
            builder: (context, state) {
              if (state is! LugaresLoaded) return const SizedBox.shrink();

              return Container(
                height: 50,
                color:  Colors.white,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  children: [
                    // Chip: Abiertos ahora
                    _QuickChip(
                      label:    'Abiertos ahora',
                      isActive: state.openNow,
                      onTap:    () => context
                          .read<LugaresCubit>()
                          .toggleOpenNow(),
                    ),
                    const SizedBox(width: 8),

                    // Chip: Relámpago
                    _QuickChip(
                      label:    '⚡ Relámpago',
                      isActive: state.flashOnly,
                      onTap:    () => context
                          .read<LugaresCubit>()
                          .toggleFlash(),
                    ),
                    const SizedBox(width: 8),

                    // Chip: Mis favoritos (solo si autenticado)
                    if (userId != null) ...[
                      _QuickChip(
                        label:    '⭐ Mis favoritos',
                        isActive: state.favoritesOnly,
                        onTap:    () => context
                            .read<LugaresCubit>()
                            .toggleFavoritesOnly(),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Chip: Más filtros
                    _AdvancedChip(
                      count: state.advancedFilterCount,
                      onTap: () => _showAdvancedFilters(state),
                    ),
                  ],
                ),
              );
            },
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          // ── Lista de establecimientos ──────────────────────────────────────
          Expanded(
            child: BlocBuilder<LugaresCubit, LugaresState>(
              builder: (context, state) {
                if (state is LugaresLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is LugaresError) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () => context.read<LugaresCubit>().load(),
                  );
                }

                if (state is LugaresLoaded) {
                  if (state.isRefreshing && state.establishments.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    );
                  }

                  if (state.establishments.isEmpty) {
                    return _EmptyView(
                      hasFilters: state.activeFilterCount > 0 ||
                          state.searchQuery.isNotEmpty,
                      onClear: () {
                        _searchController.clear();
                        context.read<LugaresCubit>().clearAllFilters();
                      },
                    );
                  }

                  return Stack(
                    children: [
                      RefreshIndicator(
                        color:     AppColors.primary,
                        onRefresh: () =>
                            context.read<LugaresCubit>().refresh(),
                        child: ListView.separated(
                          controller:  _scrollController,
                          padding:     const EdgeInsets.all(12),
                          itemCount:   state.establishments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final est = state.establishments[index];
                            return _EstablishmentTile(
                              establishment: est,
                              onTap: () => context.push(
                                '/restaurant/${est.id}',
                                extra: est.name,
                              ),
                            );
                          },
                        ),
                      ),
                      if (state.isRefreshing)
                        const LinearProgressIndicator(
                          color:           AppColors.primary,
                          backgroundColor: Colors.transparent,
                          minHeight:       2,
                        ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom sheet de filtros avanzados ────────────────────────────────────────

class _LugaresFilterSheet extends StatefulWidget {
  final LugaresLoaded state;
  final void Function(
    String?      categoryId,
    List<String> charIds,
    int?         dayOfWeek,
    String?      paymentMethod,
  ) onApply;

  const _LugaresFilterSheet({required this.state, required this.onApply});

  @override
  State<_LugaresFilterSheet> createState() => _LugaresFilterSheetState();
}

class _LugaresFilterSheetState extends State<_LugaresFilterSheet> {
  late String?      _categoryId;
  late List<String> _charIds;
  late int?         _dayOfWeek;
  late String?      _paymentMethod;

  static const _days = <int, String>{
    1: 'Lun', 2: 'Mar', 3: 'Mié', 4: 'Jue',
    5: 'Vie', 6: 'Sáb', 7: 'Dom',
  };

  static const _paymentMethods = <String, String>{
    'efectivo':      'Efectivo',
    'tarjeta':       'Tarjeta',
    'transferencia': 'Transferencia',
    'mercadopago':   'MercadoPago',
  };

  @override
  void initState() {
    super.initState();
    _categoryId    = widget.state.selectedCategoryId;
    _charIds       = List.from(widget.state.selectedCharacteristicIds);
    _dayOfWeek     = widget.state.dayOfWeek;
    _paymentMethod = widget.state.paymentMethod;
  }

  int get _advancedCount {
    int n = 0;
    if (_categoryId != null) n++;
    if (_charIds.isNotEmpty) n++;
    if (_dayOfWeek != null) n++;
    if (_paymentMethod != null) n++;
    return n;
  }

  void _clearAll() => setState(() {
        _categoryId    = null;
        _charIds       = [];
        _dayOfWeek     = null;
        _paymentMethod = null;
      });

  @override
  Widget build(BuildContext context) {
    final maxH         = MediaQuery.of(context).size.height * 0.85;
    final bottomInset  = MediaQuery.of(context).viewInsets.bottom;
    final s            = widget.state;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: Container(
        decoration: const BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color:        Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 8),
              child: Row(
                children: [
                  const Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize:   18,
                      fontWeight: FontWeight.bold,
                      color:      AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  if (_advancedCount > 0)
                    TextButton(
                      onPressed: _clearAll,
                      child: const Text(
                        'Limpiar todo',
                        style: TextStyle(color: AppColors.primary, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),

            // Contenido
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Características ────────────────────────────────────
                    if (s.characteristics.isNotEmpty) ...[
                      _SectionTitle('Características del lugar'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: s.characteristics.map((c) {
                          final active = _charIds.contains(c.id);
                          return _SelectableChip(
                            label:    c.name,
                            isActive: active,
                            onTap: () {
                              final ids = List<String>.from(_charIds);
                              active ? ids.remove(c.id) : ids.add(c.id);
                              setState(() => _charIds = ids);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Categoría ─────────────────────────────────────────
                    if (s.categories.isNotEmpty) ...[
                      _SectionTitle('Categoría'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: s.categories
                            .where((c) => c.parentId == null)
                            .map((c) {
                          final active = _categoryId == c.id;
                          return _SelectableChip(
                            label:    c.name,
                            isActive: active,
                            onTap: () => setState(() =>
                                _categoryId = active ? null : c.id),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Día de la semana ──────────────────────────────────
                    _SectionTitle('Día'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _days.entries.map((e) {
                        final active = _dayOfWeek == e.key;
                        return _SelectableChip(
                          label:    e.value,
                          isActive: active,
                          onTap: () => setState(() =>
                              _dayOfWeek = active ? null : e.key),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Método de pago ────────────────────────────────────
                    _SectionTitle('Método de pago'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _paymentMethods.entries.map((e) {
                        final active = _paymentMethod == e.key;
                        return _SelectableChip(
                          label:    e.value,
                          isActive: active,
                          onTap: () => setState(() =>
                              _paymentMethod = active ? null : e.key),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Botón Aplicar
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
              child: SizedBox(
                width:  double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onApply(
                      _categoryId,
                      _charIds,
                      _dayOfWeek,
                      _paymentMethod,
                    );
                  },
                  child: Text(
                    _advancedCount > 0
                        ? 'Aplicar ($_advancedCount ${_advancedCount == 1 ? "filtro" : "filtros"})'
                        : 'Aplicar filtros',
                    style: const TextStyle(
                      color:      Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize:   15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chip rápido ──────────────────────────────────────────────────────────────

class _QuickChip extends StatelessWidget {
  final String       label;
  final bool         isActive;
  final VoidCallback onTap;

  const _QuickChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:        isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:      isActive ? Colors.white : AppColors.textDark,
            fontSize:   13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─── Chip "Más filtros" ────────────────────────────────────────────────────────

class _AdvancedChip extends StatelessWidget {
  final int          count;
  final VoidCallback onTap;

  const _AdvancedChip({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = count > 0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:        active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded,
                size: 14,
                color: active ? Colors.white : AppColors.textDark),
            const SizedBox(width: 4),
            Text(
              active ? 'Filtros ($count)' : 'Más filtros',
              style: TextStyle(
                color:      active ? Colors.white : AppColors.textDark,
                fontSize:   13,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chip seleccionable (bottom sheet) ────────────────────────────────────────

class _SelectableChip extends StatelessWidget {
  final String       label;
  final bool         isActive;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withAlpha(20)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? AppColors.primary
                : AppColors.textDark.withAlpha(180),
            fontSize:   13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─── Sección del bottom sheet ─────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize:    11,
        fontWeight:  FontWeight.w700,
        color:       Colors.grey.shade500,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ─── Tile de establecimiento ──────────────────────────────────────────────────

class _EstablishmentTile extends StatelessWidget {
  final EstablishmentModel establishment;
  final VoidCallback        onTap;

  const _EstablishmentTile({
    required this.establishment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final est = establishment;
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withAlpha(13),
              blurRadius: 6,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width:  56,
              height: 56,
              decoration: BoxDecoration(
                color:        AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: est.logoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: est.logoUrl!,
                      fit:      BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.store_outlined,
                              color: AppColors.primary, size: 28),
                    )
                  : const Icon(Icons.store_outlined,
                      color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    est.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize:   15,
                      fontWeight: FontWeight.w600,
                      color:      AppColors.textDark,
                    ),
                  ),
                  if (est.address != null && est.address!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      est.address!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                  if (est.distanceMeters != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.near_me_outlined,
                            size:  12,
                            color: AppColors.primary.withAlpha(180)),
                        const SizedBox(width: 3),
                        Text(
                          est.distanceFormatted,
                          style: TextStyle(
                            fontSize:   11,
                            color:      AppColors.primary.withAlpha(200),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ─── Estado vacío ─────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final bool         hasFilters;
  final VoidCallback onClear;

  const _EmptyView({required this.hasFilters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off_rounded : Icons.store_outlined,
            size:  56,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters
                ? 'Sin resultados para los filtros aplicados'
                : 'No hay negocios cerca por ahora',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onClear,
              child: const Text(
                'Limpiar filtros',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
