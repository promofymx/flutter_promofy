import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../data/models/category_model.dart';

/// Selector jerárquico tipo "drill-down":
/// - Cada categoría con hijos se expande/colapsa al tocar la fila (chevron).
/// - El control de la derecha (círculo/casilla) selecciona ESA categoría,
///   sin importar el nivel — el usuario decide hasta dónde profundizar.
///
/// [multiSelect] = true: casillas (varias selecciones, p. ej. "Mis favs").
/// [multiSelect] = false: selección única (filtros).
class CategoryTreeSelector extends StatefulWidget {
  final List<CategoryModel> categories;
  final Set<String>         selectedIds;
  final void Function(CategoryModel) onTap;
  final String              langCode;
  final bool                multiSelect;

  const CategoryTreeSelector({
    super.key,
    required this.categories,
    required this.selectedIds,
    required this.onTap,
    required this.langCode,
    this.multiSelect = false,
  });

  @override
  State<CategoryTreeSelector> createState() => _CategoryTreeSelectorState();
}

class _CategoryTreeSelectorState extends State<CategoryTreeSelector> {
  final Set<String> _expanded = {};
  late Map<String?, List<CategoryModel>> _byParent;

  @override
  void initState() { super.initState(); _index(); }

  @override
  void didUpdateWidget(covariant CategoryTreeSelector old) {
    super.didUpdateWidget(old);
    _index();
  }

  void _index() {
    _byParent = {};
    for (final c in widget.categories) {
      (_byParent[c.parentId] ??= []).add(c);
    }
    for (final list in _byParent.values) {
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }
  }

  List<CategoryModel> _children(String? id) => _byParent[id] ?? const [];

  @override
  Widget build(BuildContext context) {
    final roots = _children(null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: roots.map((r) => _node(r, 0)).toList(),
    );
  }

  Widget _node(CategoryModel c, int depth) {
    final children    = _children(c.id);
    final hasChildren = children.isNotEmpty;
    final expanded    = _expanded.contains(c.id);
    final selected    = widget.selectedIds.contains(c.id);

    Widget trailing;
    if (widget.multiSelect) {
      trailing = Icon(
        selected ? Icons.check_box : Icons.check_box_outline_blank,
        size: 22, color: selected ? AppColors.primary : Colors.grey.shade400,
      );
    } else {
      trailing = Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        size: 22, color: selected ? AppColors.primary : Colors.grey.shade400,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          // Tocar la fila: si tiene hijos, expande/colapsa; si es hoja, selecciona.
          onTap: () {
            if (hasChildren) {
              setState(() =>
                  expanded ? _expanded.remove(c.id) : _expanded.add(c.id));
            } else {
              widget.onTap(c);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8.0 + depth * 18, 7, 4, 7),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: hasChildren
                      ? Icon(expanded ? Icons.expand_more : Icons.chevron_right,
                          size: 20, color: Colors.grey.shade600)
                      : const SizedBox.shrink(),
                ),
                if (c.icon != null && c.icon!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(c.icon!, style: const TextStyle(fontSize: 15)),
                  ),
                Expanded(
                  child: Text(
                    c.localizedName(widget.langCode),
                    style: TextStyle(
                      fontSize: depth == 0 ? 14.5 : 13.5,
                      fontWeight: depth == 0
                          ? FontWeight.w700
                          : (selected ? FontWeight.w600 : FontWeight.normal),
                      color: selected ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                ),
                // Control de selección (selecciona este nodo a cualquier nivel)
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => widget.onTap(c),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: trailing,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasChildren && expanded)
          ...children.map((ch) => _node(ch, depth + 1)),
      ],
    );
  }
}
