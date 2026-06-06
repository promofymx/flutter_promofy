import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/categories_repository.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_event.dart';
import '../../../features/home/bloc/home_bloc.dart';
import '../../../features/home/bloc/home_event.dart';

/// Pantalla dedicada de Configuración del usuario.
/// Se abre desde Perfil → "Configuración".
class SettingsScreen extends StatefulWidget {
  final ProfileModel profile;
  final String       userId;
  const SettingsScreen({super.key, required this.profile, required this.userId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  int          _radius   = 25;
  Set<String>  _types     = {};
  Set<int>     _catIds    = {};
  bool         _saving    = false;
  List<CategoryModel> _categories = [];

  static const _radiusOptions = [5, 10, 25, 50];
  static const _typeOptions = <String, String>{
    'restaurante': 'Restaurante',
    'bar':         'Bar',
    'cafeteria':   'Cafetería',
    'fast_food':   'Fast food',
    'antojitos':   'Antojitos',
    'mariscos':    'Mariscos',
    'pizza':       'Pizza',
    'sushi':       'Sushi',
  };

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.profile.fullName ?? '';
    _radius        = widget.profile.searchRadiusKm;
    _types         = Set<String>.from(widget.profile.preferredTypes);
    _catIds        = Set<int>.from(widget.profile.favoriteCategoryIds);
    _loadCategories();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await CategoriesRepository().getCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('El nombre no puede estar vacío.');
      return;
    }
    setState(() => _saving = true);
    try {
      await AuthRepository().updateSettings(
        userId:              widget.userId,
        fullName:            name,
        searchRadiusKm:      _radius,
        preferredTypes:      _types.toList(),
        favoriteCategoryIds: _catIds.toList(),
      );
      if (!mounted) return;
      context.read<HomeBloc>().add(HomeRadiusChanged(radiusKm: _radius));
      context.read<AuthBloc>().add(AuthProfileRefreshRequested());
      _snack('Configuración guardada.', success: true);
    } catch (_) {
      _snack('Error al guardar. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:         Text(msg),
      backgroundColor: success ? Colors.green.shade700 : null,
      behavior:        SnackBarBehavior.floating,
    ));
  }

  // ── Cambiar contraseña ─────────────────────────────────────────────────────
  Future<void> _changePassword() async {
    final c1 = TextEditingController();
    final c2 = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: c1, obscureText: true,
              decoration: const InputDecoration(labelText: 'Nueva contraseña'),
              validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: c2, obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
              validator: (v) => v != c1.text ? 'No coinciden' : null,
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () { if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, true); },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await AuthRepository().changePassword(c1.text.trim());
      _snack('Contraseña actualizada.', success: true);
    } catch (_) {
      _snack('No se pudo cambiar la contraseña. Intenta de nuevo.');
    }
  }

  // ── Eliminar cuenta ─────────────────────────────────────────────────────────
  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Estás seguro?'),
        content: const Text(
          'Perderás toda tu información: tu perfil, favoritos, sellos de lealtad, '
          'historial y, si tienes un negocio, sus datos asociados.\n\n'
          'Esta acción es permanente y no se puede deshacer.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar cuenta'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    showDialog<void>(
      context: context, barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await AuthRepository().deleteAccount();
      // signOut dispara el cambio de auth → el router redirige a login.
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      _snack('No se pudo eliminar la cuenta. Escríbenos a promofymx@gmail.com');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rootCats = _categories.where((c) => c.parentId == null).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Configuración', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card([
            const _SectionLabel('Nombre'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDeco('Tu nombre completo'),
            ),
            const SizedBox(height: 16),

            const _SectionLabel('Radio de búsqueda'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: _radiusOptions.map((km) {
              final sel = km == _radius;
              return ChoiceChip(
                label: Text('$km km'),
                selected: sel,
                onSelected: (_) => setState(() => _radius = km),
                selectedColor: AppColors.primary.withAlpha(30),
                labelStyle: TextStyle(
                  color: sel ? AppColors.primary : Colors.grey.shade700,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal, fontSize: 13),
                side: BorderSide(color: sel ? AppColors.primary : Colors.grey.shade300),
                backgroundColor: Colors.grey.shade50,
              );
            }).toList()),
            const SizedBox(height: 16),

            const _SectionLabel('Tipos de lugar preferidos'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _typeOptions.entries.map((e) {
              final sel = _types.contains(e.key);
              return FilterChip(
                label: Text(e.value),
                selected: sel,
                onSelected: (_) => setState(() =>
                    sel ? _types.remove(e.key) : _types.add(e.key)),
                selectedColor: AppColors.primary.withAlpha(25),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: sel ? AppColors.primary : Colors.grey.shade700,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal, fontSize: 13),
                side: BorderSide(color: sel ? AppColors.primary : Colors.grey.shade300),
                backgroundColor: Colors.grey.shade50,
              );
            }).toList()),
            const SizedBox(height: 16),

            const _SectionLabel('Comida favorita'),
            const SizedBox(height: 8),
            if (rootCats.isEmpty)
              Text('Cargando categorías…',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400))
            else
              Wrap(spacing: 8, runSpacing: 8, children: rootCats.map((c) {
                final id = int.tryParse(c.id) ?? -1;
                final sel = _catIds.contains(id);
                return FilterChip(
                  label: Text(c.name),
                  selected: sel,
                  onSelected: (_) => setState(() =>
                      sel ? _catIds.remove(id) : _catIds.add(id)),
                  selectedColor: AppColors.primary.withAlpha(25),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: sel ? AppColors.primary : Colors.grey.shade700,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal, fontSize: 13),
                  side: BorderSide(color: sel ? AppColors.primary : Colors.grey.shade300),
                  backgroundColor: Colors.grey.shade50,
                );
              }).toList()),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Guardar configuración',
                        style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
          const SizedBox(height: 16),

          _card([
            const _SectionLabel('Cuenta y seguridad'),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _changePassword,
              icon: const Icon(Icons.lock_outline, size: 18),
              label: const Text('Cambiar contraseña'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
                foregroundColor: AppColors.textDark,
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _confirmDeleteAccount,
              icon: const Icon(Icons.delete_forever_outlined, size: 18, color: Colors.red),
              label: const Text('Eliminar cuenta', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
                side: BorderSide(color: Colors.red.shade200),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary)),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark));
}
