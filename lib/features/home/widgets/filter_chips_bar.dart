import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/characteristic_model.dart';
import '../../../data/models/filter_model.dart';
import 'filter_bottom_sheet.dart';

/// Barra de chips de filtro siempre visible debajo del AppBar.
/// Muestra: "Activas ahora" | "⚡ Relámpago" | "⭐ Mis favoritas" | "Más filtros (n)"
class FilterChipsBar extends StatelessWidget {
  final HomeFilters filters;
  final List<CategoryModel> categories;
  final List<CharacteristicModel> characteristics;

  /// Si es null, el chip "Mis favoritas" no se muestra (usuario no autenticado).
  final String? userId;

  const FilterChipsBar({
    super.key,
    required this.filters,
    required this.categories,
    required this.characteristics,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // Chip rápido: Activas ahora
          _QuickChip(
            label: 'Activas ahora',
            isActive: filters.activeNow,
            onTap: () => context.read<HomeBloc>().add(
                  HomeFiltersChanged(
                    filters: filters.copyWith(activeNow: !filters.activeNow),
                  ),
                ),
          ),
          const SizedBox(width: 8),

          // Chip rápido: Relámpago
          _QuickChip(
            label: '⚡ Relámpago',
            isActive: filters.flashOnly,
            onTap: () => context.read<HomeBloc>().add(
                  HomeFiltersChanged(
                    filters: filters.copyWith(flashOnly: !filters.flashOnly),
                  ),
                ),
          ),
          const SizedBox(width: 8),

          // Chip rápido: Mis favoritas (solo para usuarios autenticados)
          if (userId != null) ...[
            _QuickChip(
              label: '⭐ Mis favoritas',
              isActive: filters.favoritesOnly,
              onTap: () => context.read<HomeBloc>().add(
                    HomeFiltersChanged(
                      filters: filters.copyWith(
                          favoritesOnly: !filters.favoritesOnly),
                    ),
                  ),
            ),
            const SizedBox(width: 8),
          ],

          // Chip rápido: Cumpleañero
          _QuickChip(
            label: '🎂 Cumpleañero',
            isActive: filters.birthdayOnly,
            onTap: () => context.read<HomeBloc>().add(
                  HomeFiltersChanged(
                    filters: filters.copyWith(
                        birthdayOnly: !filters.birthdayOnly),
                  ),
                ),
          ),
          const SizedBox(width: 8),

          // Chip avanzado: abre bottom sheet
          _AdvancedChip(
            count: filters.advancedCount,
            onTap: () => showFilterBottomSheet(
              context: context,
              currentFilters: filters,
              categories: categories,
              characteristics: characteristics,
              onApply: (newFilters) => context
                  .read<HomeBloc>()
                  .add(HomeFiltersChanged(filters: newFilters)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chip rápido (toggle simple) ─────────────────────────────────────────────

class _QuickChip extends StatelessWidget {
  final String label;
  final bool isActive;
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
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textDark,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─── Chip "Más filtros" con badge de contador ─────────────────────────────────

class _AdvancedChip extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _AdvancedChip({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasActive = count > 0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasActive ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 14,
              color: hasActive ? Colors.white : AppColors.textDark,
            ),
            const SizedBox(width: 4),
            Text(
              hasActive ? 'Filtros ($count)' : 'Más filtros',
              style: TextStyle(
                color: hasActive ? Colors.white : AppColors.textDark,
                fontSize: 13,
                fontWeight: hasActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
