import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promofy/l10n/app_localizations.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../cubit/ads_display_cubit.dart';
import '../cubit/ads_display_state.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/filter_chips_bar.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/promo_card.dart';
import '../widgets/sponsored_promo_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/ad_display_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/characteristic_model.dart';
import '../../../data/models/filter_model.dart';
import '../../../data/models/promotion_model.dart';
import '../../../core/services/notification_service.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController  = ScrollController();
  final _searchController  = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeStarted());
    _scrollController.addListener(_onScroll);
    // Reconstruir para mostrar/ocultar el botón X cuando cambia el texto
    _searchController.addListener(() => setState(() {}));

    // Aplica filtro pendiente generado por tap en notificación push
    // (ej. notificación de cumpleaños → abre home con filtro 'birthday')
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = NotificationService.instance.pendingFilter;
      if (pending != null && mounted) {
        NotificationService.instance.clearPendingFilter();
        context.read<HomeBloc>().add(HomeFiltersChanged(filters: pending));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchTextChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        context.read<HomeBloc>().add(HomeSearchChanged(query: value.trim()));
      }
    });
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent * 0.9) {
      context.read<HomeBloc>().add(const HomeNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: BlocListener<HomeBloc, HomeState>(
        // Sincroniza el campo de búsqueda cuando se limpian los filtros externamente
        listenWhen: (prev, next) {
          final prevQ = prev is HomeLoaded ? prev.filters.searchQuery : '';
          final nextQ = next is HomeLoaded ? next.filters.searchQuery : '';
          return prevQ != nextQ;
        },
        listener: (context, state) {
          final q = state is HomeLoaded ? state.filters.searchQuery : '';
          if (_searchController.text != q) {
            _searchController.text = q;
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          // ── Carga inicial ───────────────────────────────────────────────
          if (state is HomeLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // ── Error ───────────────────────────────────────────────────────
          if (state is HomeError) {
            return _buildError(context, state.message);
          }

          // ── Extraer datos (HomeLoaded o HomeLoadingMore) ─────────────────
          List<PromotionModel> promos          = [];
          bool isLoadingMore                   = false;
          bool isApplyingFilters               = false;
          HomeFilters filters                  = const HomeFilters();
          List<CategoryModel> categories       = [];
          List<CharacteristicModel> characteristics = [];

          if (state is HomeLoaded) {
            promos             = state.promos;
            isApplyingFilters  = state.isApplyingFilters;
            filters            = state.filters;
            categories         = state.categories;
            characteristics    = state.characteristics;
          } else if (state is HomeLoadingMore) {
            promos          = state.promos;
            isLoadingMore   = true;
            filters         = state.filters;
            categories      = state.categories;
            characteristics = state.characteristics;
          }

          return Column(
            children: [
              // Chips rápidos de filtro
              FilterChipsBar(
                filters:         filters,
                categories:      categories,
                characteristics: characteristics,
                userId: context.read<AuthBloc>().state is AuthAuthenticated
                    ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
                    : null,
              ),

              // Banner publicitario (se oculta solo si no hay campañas activas)
              const AdBannerWidget(),

              // Barra de progreso al aplicar filtros (2 px, no bloquea UI)
              if (isApplyingFilters)
                const LinearProgressIndicator(
                  color:           AppColors.primary,
                  backgroundColor: Colors.transparent,
                  minHeight:       2,
                ),
              Divider(height: 1, color: Colors.grey.shade200),

              // Grid de promos (mezcla orgánicas + patrocinadas)
              Expanded(
                child: promos.isEmpty && !isApplyingFilters
                    ? _buildEmpty(context, filters.hasActiveFilters,
                        filters.searchQuery)
                    : BlocBuilder<AdsDisplayCubit, AdsDisplayState>(
                        buildWhen: (p, n) =>
                            p.featuredAds != n.featuredAds,
                        builder: (context, adsState) {
                          final items = _buildMixedItems(
                              promos, adsState.featuredAds);
                          return RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () async {
                              context
                                  .read<HomeBloc>()
                                  .add(const HomeRefreshRequested());
                              await Future.delayed(
                                  const Duration(milliseconds: 800));
                            },
                            child: CustomScrollView(
                              controller: _scrollController,
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.all(12),
                                  sliver: SliverGrid(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:   2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing:  12,
                                      mainAxisExtent:   248,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final item = items[index];
                                        if (item is AdDisplayModel) {
                                          return SponsoredPromoCard(
                                              ad: item);
                                        }
                                        final promo =
                                            item as PromotionModel;
                                        return PromoCard(
                                          promo: promo,
                                          onTap: () async {
                                            final isFav =
                                                await context.push<bool>(
                                              '/promo/${promo.id}',
                                              extra: promo,
                                            );
                                            if (isFav != null &&
                                                isFav !=
                                                    promo.isFavorited &&
                                                context.mounted) {
                                              context
                                                  .read<HomeBloc>()
                                                  .add(
                                                    HomePromoFavoriteSynced(
                                                      promoId: promo.id,
                                                      isFavorited: isFav,
                                                    ),
                                                  );
                                            }
                                          },
                                          onFavoriteToggled: () =>
                                              context
                                                  .read<HomeBloc>()
                                                  .add(
                                                    HomePromoFavoriteToggled(
                                                        promo: promo),
                                                  ),
                                        );
                                      },
                                      childCount: items.length,
                                    ),
                                  ),
                                ),

                                // Spinner al cargar siguiente página
                                if (isLoadingMore)
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color:       AppColors.primary,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  ),

                                const SliverToBoxAdapter(
                                    child: SizedBox(height: 16)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        ),  // BlocBuilder
      ),    // BlocListener
    );
  }

  // ── Mezcla promos orgánicas con patrocinadas ────────────────────────────────

  /// Intercala un [AdDisplayModel] cada 5 promos orgánicas.
  /// Si no hay anuncios, devuelve la lista original sin modificar.
  List<Object> _buildMixedItems(
    List<PromotionModel>  promos,
    List<AdDisplayModel>  featured,
  ) {
    if (featured.isEmpty) return List<Object>.from(promos);
    final result = <Object>[];
    int adIdx = 0;
    for (int i = 0; i < promos.length; i++) {
      result.add(promos[i]);
      if ((i + 1) % 5 == 0) {
        result.add(featured[adIdx % featured.length]);
        adIdx++;
      }
    }
    return result;
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation:       0,
      leadingWidth:    52,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
      ),
      // ── Barra de búsqueda embebida en el título ────────────────────────
      title: TextField(
        controller:      _searchController,
        onChanged:       _onSearchTextChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText:  AppLocalizations.of(context).homeSearchHint,
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search,
              color: Colors.grey.shade400, size: 18),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close,
                      size: 16, color: Colors.grey.shade500),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchTextChanged('');
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
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
      actions: [
        // Ícono de filtros con badge contador
        BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (prev, next) {
            int countOf(HomeState s) {
              if (s is HomeLoaded) return s.filters.activeCount;
              if (s is HomeLoadingMore) return s.filters.activeCount;
              return 0;
            }
            return countOf(prev) != countOf(next);
          },
          builder: (context, state) {
            final filterCount = state is HomeLoaded
                ? state.filters.activeCount
                : state is HomeLoadingMore
                    ? state.filters.activeCount
                    : 0;

            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded,
                      color: AppColors.textDark),
                  onPressed: () {
                    final s = context.read<HomeBloc>().state;
                    if (s is HomeLoaded) {
                      showFilterBottomSheet(
                        context:         context,
                        currentFilters:  s.filters,
                        categories:      s.categories,
                        characteristics: s.characteristics,
                        onApply: (f) => context
                            .read<HomeBloc>()
                            .add(HomeFiltersChanged(filters: f)),
                      );
                    }
                  },
                ),
                if (filterCount > 0)
                  Positioned(
                    top:   8,
                    right: 8,
                    child: Container(
                      width:  16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$filterCount',
                          style: const TextStyle(
                            color:      Colors.white,
                            fontSize:   9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        // Notificaciones
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textDark),
          onPressed: () {},
        ),
      ],
    );
  }

  // ── Pantalla vacía ──────────────────────────────────────────────────────────

  Widget _buildEmpty(
      BuildContext context, bool hasFilters, String searchQuery) {
    final hasSearch = searchQuery.isNotEmpty;
    final showClear = hasFilters || hasSearch;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showClear ? Icons.search_off : Icons.local_offer_outlined,
            size:  56,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch
                ? AppLocalizations.of(context).homeEmptySearch(searchQuery)
                : hasFilters
                    ? AppLocalizations.of(context).homeEmptyFilters
                    : AppLocalizations.of(context).homeEmptyNoPromos,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
          if (showClear) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                _searchController.clear();
                context.read<HomeBloc>().add(
                      HomeFiltersChanged(
                          filters: const HomeFilters(activeNow: true)),
                    );
              },
              child: Text(
                AppLocalizations.of(context).homeClearSearchAndFilters,
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Pantalla de error ───────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<HomeBloc>().add(const HomeStarted()),
            child: Text(AppLocalizations.of(context).homeRetry),
          ),
        ],
      ),
    );
  }
}
