import 'package:flutter/material.dart';
import 'package:promofy/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/category_tree_selector.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/characteristic_model.dart';
import '../../../data/models/filter_model.dart';

// ─── Función helper para abrir el sheet desde cualquier lugar ────────────────

Future<void> showFilterBottomSheet({
  required BuildContext context,
  required HomeFilters currentFilters,
  required List<CategoryModel> categories,
  required List<CharacteristicModel> characteristics,
  required ValueChanged<HomeFilters> onApply,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FilterBottomSheet(
      currentFilters:  currentFilters,
      categories:      categories,
      characteristics: characteristics,
      onApply:         onApply,
    ),
  );
}

// ─── Widget principal ─────────────────────────────────────────────────────────

class FilterBottomSheet extends StatefulWidget {
  final HomeFilters currentFilters;
  final List<CategoryModel> categories;
  final List<CharacteristicModel> characteristics;
  final ValueChanged<HomeFilters> onApply;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.categories,
    required this.characteristics,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // Estado local del borrador — se aplica solo al pulsar "Aplicar filtros"
  late HomeFilters _draft;

  // 0=Dom, 1=Lun … 6=Sáb  (coincide con PostgreSQL EXTRACT(DOW))
  // 1=Lun … 7=Dom  (ISO weekday — coincide con DateTime.weekday de Dart
  // y con EXTRACT(ISODOW …) en PostgreSQL)
  static const _days = <int, String>{
    1: 'Lun',
    2: 'Mar',
    3: 'Mié',
    4: 'Jue',
    5: 'Vie',
    6: 'Sáb',
    7: 'Dom',
  };

  // Valores del enum payment_method en la DB → etiqueta visible
  static const _paymentMethods = <String, String>{
    'efectivo':      'Efectivo',
    'tarjeta':       'Tarjeta',
    'transferencia': 'Transferencia',
    'mercadopago':   'MercadoPago',
  };

  @override
  void initState() {
    super.initState();
    _draft = widget.currentFilters;
  }

  // Etiquetas localizadas para días y métodos de pago (reusan claves de "lugares").
  String _dayLabel(BuildContext c, int d) {
    final l = AppLocalizations.of(c);
    switch (d) {
      case 1: return l.lugaresDayMon;
      case 2: return l.lugaresDayTue;
      case 3: return l.lugaresDayWed;
      case 4: return l.lugaresDayThu;
      case 5: return l.lugaresDayFri;
      case 6: return l.lugaresDaySat;
      case 7: return l.lugaresDaySun;
      default: return '';
    }
  }

  String _paymentLabel(BuildContext c, String k) {
    final l = AppLocalizations.of(c);
    switch (k) {
      case 'efectivo':      return l.lugaresPaymentCash;
      case 'tarjeta':       return l.lugaresPaymentCard;
      case 'transferencia': return l.lugaresPaymentTransfer;
      case 'mercadopago':   return l.lugaresPaymentMercadopago;
      default: return k;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    // Limita la altura al 85% de la pantalla para no tapar todo
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header: título + "Limpiar todo"
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 8),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context).filterSheetTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  if (_draft.advancedCount > 0)
                    TextButton(
                      onPressed: () => setState(() => _draft = _draft.copyWith(
                            categoryId: null,
                            characteristicIds: [],
                            dayOfWeek: null,
                            paymentMethod: null,
                          )),
                      child: Text(
                        AppLocalizations.of(context).filterSheetClearAll,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),

            // ─── Contenido scrolleable ─────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8 + bottomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección 1: Características del lugar
                    if (widget.characteristics.isNotEmpty) ...[
                      _SectionTitle(AppLocalizations.of(context).filterSheetSectionPlaceFeatures),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.characteristics.map((c) {
                          final active =
                              _draft.characteristicIds.contains(c.id);
                          return _SelectableChip(
                            label: c.localizedName(Localizations.localeOf(context).languageCode),
                            isActive: active,
                            onTap: () {
                              final ids = List<String>.from(
                                  _draft.characteristicIds);
                              active ? ids.remove(c.id) : ids.add(c.id);
                              setState(() => _draft =
                                  _draft.copyWith(characteristicIds: ids));
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Sección 2: Categoría (drill-down jerárquico)
                    if (widget.categories.isNotEmpty) ...[
                      _SectionTitle(AppLocalizations.of(context).filterSheetSectionCategory),
                      const SizedBox(height: 4),
                      CategoryTreeSelector(
                        categories: widget.categories,
                        selectedIds: _draft.categoryId != null
                            ? {_draft.categoryId!}
                            : <String>{},
                        langCode: Localizations.localeOf(context).languageCode,
                        onTap: (c) => setState(() => _draft = _draft.copyWith(
                              categoryId: _draft.categoryId == c.id ? null : c.id,
                            )),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Sección 4: Día de la semana
                    _SectionTitle(AppLocalizations.of(context).filterSheetSectionDay),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _days.entries.map((e) {
                        final active = _draft.dayOfWeek == e.key;
                        return _SelectableChip(
                          label: _dayLabel(context, e.key),
                          isActive: active,
                          onTap: () => setState(() => _draft = _draft.copyWith(
                                dayOfWeek: active ? null : e.key,
                              )),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Sección 5: Método de pago
                    _SectionTitle(AppLocalizations.of(context).filterSheetSectionPaymentMethod),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _paymentMethods.entries.map((e) {
                        final active = _draft.paymentMethod == e.key;
                        return _SelectableChip(
                          label: _paymentLabel(context, e.key),
                          isActive: active,
                          onTap: () => setState(() => _draft = _draft.copyWith(
                                paymentMethod: active ? null : e.key,
                              )),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ─── Botón Aplicar ─────────────────────────────────────────────
            Padding(
              padding:
                  EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomPadding),
              child: SizedBox(
                width: double.infinity,
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
                    widget.onApply(_draft);
                  },
                  child: Text(
                    _draft.advancedCount > 0
                        ? AppLocalizations.of(context).filterSheetApplyWithCount(_draft.advancedCount)
                        : AppLocalizations.of(context).filterSheetApply,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool isActive;
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
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
