import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';
import '../../home/widgets/promo_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/establishment_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<FavoritesCubit>().load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Helpers por tab ───────────────────────────────────────────────────────

  Widget _buildPromosTab(BuildContext context, FavoritesState state) {
    if (state is FavoritesLoading || state is FavoritesInitial) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state is FavoritesError) {
      return _ErrorView(
        message: state.message,
        onRetry: () => context.read<FavoritesCubit>().load(),
      );
    }
    if (state is FavoritesLoaded) {
      return _PromosTab(
        promos:    state.promos,
        onRefresh: () => context.read<FavoritesCubit>().refresh(),
        onRemove:  (promo) =>
            context.read<FavoritesCubit>().removeFavorite(promo),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildEstablishmentsTab(BuildContext context, FavoritesState state) {
    if (state is FavoritesLoading || state is FavoritesInitial) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state is FavoritesError) {
      return _ErrorView(
        message: state.message,
        onRetry: () => context.read<FavoritesCubit>().load(),
      );
    }
    if (state is FavoritesLoaded) {
      return _EstablishmentsTab(
        establishments: state.establishments,
        onRefresh:      () => context.read<FavoritesCubit>().refresh(),
        onRemove:       (est) =>
            context.read<FavoritesCubit>().removeFavoriteEstablishment(est),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mis favoritos',
          style: TextStyle(
            color:      AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize:   20,
          ),
        ),
        bottom: TabBar(
          controller:        _tabController,
          labelColor:        AppColors.primary,
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor:    AppColors.primary,
          indicatorWeight:   2.5,
          labelStyle:        const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          tabs: const [
            Tab(text: 'Promociones'),
            Tab(text: 'Establecimientos'),
          ],
        ),
      ),
      // TabBarView SIEMPRE está en el árbol para que TabBar
      // tenga su contraparte y no lance errores de layout.
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              // ── Tab 1: Promociones ───────────────────────────────────────
              _buildPromosTab(context, state),

              // ── Tab 2: Establecimientos ──────────────────────────────────
              _buildEstablishmentsTab(context, state),
            ],
          );
        },
      ),
    );
  }
}

// ─── Error reutilizable ───────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String      message;
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

// ─── Tab Promociones ──────────────────────────────────────────────────────────

class _PromosTab extends StatelessWidget {
  final List             promos;
  final Future<void> Function() onRefresh;
  final void Function(dynamic) onRemove;

  const _PromosTab({
    required this.promos,
    required this.onRefresh,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (promos.isEmpty) {
      return _EmptyTab(
        icon:    Icons.local_offer_outlined,
        title:   'Aún no tienes promos favoritas',
        subtitle:'Toca el corazón en cualquier promo\npara guardarla aquí',
        onExplore: () => context.go('/home'),
      );
    }

    return RefreshIndicator(
      color:     AppColors.primary,
      onRefresh: onRefresh,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:   2,
          crossAxisSpacing: 12,
          mainAxisSpacing:  12,
          mainAxisExtent:   238,
        ),
        itemCount: promos.length,
        itemBuilder: (context, index) {
          final promo = promos[index];
          return PromoCard(
            promo: promo,
            onTap: () async {
              final isFav = await context.push<bool>(
                '/promo/${promo.id}',
                extra: promo,
              );
              if (isFav != null &&
                  isFav != promo.isFavorited &&
                  context.mounted) {
                context.read<FavoritesCubit>().refresh();
              }
            },
            onFavoriteToggled: () => onRemove(promo),
          );
        },
      ),
    );
  }
}

// ─── Tab Establecimientos ─────────────────────────────────────────────────────

class _EstablishmentsTab extends StatelessWidget {
  final List<EstablishmentModel>  establishments;
  final Future<void> Function()   onRefresh;
  final void Function(EstablishmentModel) onRemove;

  const _EstablishmentsTab({
    required this.establishments,
    required this.onRefresh,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (establishments.isEmpty) {
      return _EmptyTab(
        icon:     Icons.store_outlined,
        title:    'Aún no tienes negocios favoritos',
        subtitle: 'Entra a un negocio y toca el corazón\npara guardarlo aquí',
        onExplore: () => context.go('/home'),
      );
    }

    return RefreshIndicator(
      color:     AppColors.primary,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding:   const EdgeInsets.all(12),
        itemCount: establishments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final est = establishments[index];
          return _EstablishmentCard(
            establishment: est,
            onTap: () => context.push(
              '/restaurant/${est.id}',
              extra: est.name,
            ),
            onRemove: () => onRemove(est),
          );
        },
      ),
    );
  }
}

class _EstablishmentCard extends StatelessWidget {
  final EstablishmentModel         establishment;
  final VoidCallback               onTap;
  final VoidCallback               onRemove;

  const _EstablishmentCard({
    required this.establishment,
    required this.onTap,
    required this.onRemove,
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
            // Logo / avatar
            Container(
              width: 56,
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
                    maxLines:  1,
                    overflow:  TextOverflow.ellipsis,
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
                      maxLines:  1,
                      overflow:  TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                  if (est.distanceMeters != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      est.distanceFormatted,
                      style: TextStyle(
                        fontSize:   11,
                        color:      AppColors.primary.withAlpha(200),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Botón quitar favorito
            IconButton(
              icon: const Icon(Icons.favorite_rounded,
                  color: Colors.pinkAccent, size: 22),
              onPressed: onRemove,
              tooltip: 'Quitar de favoritos',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Estado vacío reutilizable ────────────────────────────────────────────────

class _EmptyTab extends StatelessWidget {
  final IconData     icon;
  final String       title;
  final String       subtitle;
  final VoidCallback onExplore;

  const _EmptyTab({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onExplore,
            icon:  const Icon(Icons.explore_outlined, color: AppColors.primary),
            label: const Text('Explorar',
                style: TextStyle(color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              side:  const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}
