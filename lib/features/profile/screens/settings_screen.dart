import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/cubit/locale_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/category_tree_selector.dart';
import '../../../l10n/app_localizations.dart';
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
  DateTime?    _birthDate;
  String?      _gender;
  bool         _saving    = false;
  List<CategoryModel> _categories = [];

  static const _radiusOptions = [5, 10, 25, 50];

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.profile.fullName ?? '';
    _radius        = widget.profile.searchRadiusKm;
    _types         = Set<String>.from(widget.profile.preferredTypes);
    _catIds        = Set<int>.from(widget.profile.favoriteCategoryIds);
    _birthDate     = widget.profile.birthDate;
    _gender        = widget.profile.gender;
    _loadCategories();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final maxDate = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: maxDate,
      helpText: AppLocalizations.of(context).onboardingMustBeAdult,
      confirmText: AppLocalizations.of(context).onboardingConfirm,
      cancelText: AppLocalizations.of(context).onboardingCancel,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

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
    setState(() => _saving = true);
    try {
      await AuthRepository().updateSettings(
        userId:              widget.userId,
        fullName:            name,
        searchRadiusKm:      _radius,
        preferredTypes:      _types.toList(),
        favoriteCategoryIds: _catIds.toList(),
        birthDate:           _birthDate,
        gender:              _gender,
      );
      if (!mounted) return;
      context.read<HomeBloc>().add(HomeRadiusChanged(radiusKm: _radius));
      context.read<AuthBloc>().add(AuthProfileRefreshRequested());
      _snack(AppLocalizations.of(context).settingsSaved, success: true);
    } catch (_) {
      if (mounted) _snack(AppLocalizations.of(context).settingsSaveError);
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
        title: Text(AppLocalizations.of(ctx).settingsChangePassword),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: c1, obscureText: true,
              decoration: InputDecoration(labelText: AppLocalizations.of(ctx).settingsNewPassword),
              validator: (v) => (v == null || v.length < 6) ? AppLocalizations.of(ctx).settingsPasswordMin : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: c2, obscureText: true,
              decoration: InputDecoration(labelText: AppLocalizations.of(ctx).settingsConfirmPassword),
              validator: (v) => v != c1.text ? AppLocalizations.of(ctx).settingsPasswordMismatch : null,
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(ctx).settingsCancel)),
          ElevatedButton(
            onPressed: () { if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, true); },
            child: Text(AppLocalizations.of(ctx).settingsSave),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await AuthRepository().changePassword(c1.text.trim());
      if (mounted) _snack(AppLocalizations.of(context).settingsPasswordUpdated, success: true);
    } catch (_) {
      if (mounted) _snack(AppLocalizations.of(context).settingsPasswordError);
    }
  }

  // ── Eliminar cuenta ─────────────────────────────────────────────────────────
  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx).settingsDeleteConfirmTitle),
        content: Text(AppLocalizations.of(ctx).settingsDeleteConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(ctx).settingsCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(ctx).settingsDeleteAccount),
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
      _snack(AppLocalizations.of(context).settingsDeleteError('promofymx@gmail.com'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(AppLocalizations.of(context).settingsTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card([
            _SectionLabel(AppLocalizations.of(context).settingsName),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDeco(AppLocalizations.of(context).settingsNameHint),
            ),
            const SizedBox(height: 16),

            // Invitación a completar datos para promos personalizadas
            if (_birthDate == null || _gender == null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withAlpha(60)),
                ),
                child: Text(
                  AppLocalizations.of(context).settingsPersonalizePrompt,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Fecha de nacimiento
            _SectionLabel(AppLocalizations.of(context).onboardingBirthQuestion),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    _birthDate != null
                        ? _formatDate(_birthDate!)
                        : AppLocalizations.of(context).onboardingSelectBirthDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: _birthDate != null
                          ? AppColors.textDark
                          : Colors.grey,
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Sexo
            _SectionLabel(AppLocalizations.of(context).onboardingGenderQuestion),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _genderChip('male',
                  AppLocalizations.of(context).onboardingGenderMale),
              _genderChip('female',
                  AppLocalizations.of(context).onboardingGenderFemale),
              _genderChip('prefer_not_to_say',
                  AppLocalizations.of(context).onboardingGenderPreferNot),
            ]),
            const SizedBox(height: 16),

            _SectionLabel(AppLocalizations.of(context).settingsSearchRadius),
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

            _SectionLabel(AppLocalizations.of(context).settingsMyFavs),
            const SizedBox(height: 4),
            if (_categories.isEmpty)
              Text(AppLocalizations.of(context).settingsLoadingCategories,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400))
            else
              CategoryTreeSelector(
                categories: _categories,
                multiSelect: true,
                selectedIds: _catIds.map((e) => e.toString()).toSet(),
                langCode: Localizations.localeOf(context).languageCode,
                onTap: (c) {
                  final id = int.tryParse(c.id);
                  if (id == null) return;
                  setState(() => _catIds.contains(id)
                      ? _catIds.remove(id)
                      : _catIds.add(id));
                },
              ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Text(AppLocalizations.of(context).settingsSaveButton,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Idioma ──────────────────────────────────────────────────────────
          _card([
            _SectionLabel(AppLocalizations.of(context).language),
            const SizedBox(height: 8),
            BlocBuilder<LocaleCubit, Locale?>(
              builder: (context, locale) {
                final current = locale?.languageCode; // null = automático
                Widget chip(String label, String? code) {
                  final sel = current == code;
                  return ChoiceChip(
                    label: Text(label),
                    selected: sel,
                    onSelected: (_) => context
                        .read<LocaleCubit>()
                        .setLocale(code == null ? null : Locale(code)),
                    selectedColor: AppColors.primary.withAlpha(30),
                    labelStyle: TextStyle(
                      color: sel ? AppColors.primary : Colors.grey.shade700,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                        color: sel ? AppColors.primary : Colors.grey.shade300),
                    backgroundColor: Colors.grey.shade50,
                  );
                }

                return Wrap(spacing: 8, runSpacing: 8, children: [
                  chip(AppLocalizations.of(context).languageAuto, null),
                  chip('Español', 'es'),
                  chip('English', 'en'),
                  chip('Deutsch', 'de'),
                ]);
              },
            ),
          ]),
          const SizedBox(height: 16),

          _card([
            _SectionLabel(AppLocalizations.of(context).settingsAccountSecurity),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _changePassword,
              icon: const Icon(Icons.lock_outline, size: 18),
              label: Text(AppLocalizations.of(context).settingsChangePassword),
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
              label: Text(AppLocalizations.of(context).settingsDeleteAccount, style: const TextStyle(color: Colors.red)),
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

  Widget _genderChip(String value, String label) {
    final sel = _gender == value;
    return ChoiceChip(
      label: Text(label),
      selected: sel,
      onSelected: (_) => setState(() => _gender = value),
      selectedColor: AppColors.primary.withAlpha(30),
      labelStyle: TextStyle(
        color: sel ? AppColors.primary : Colors.grey.shade700,
        fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(color: sel ? AppColors.primary : Colors.grey.shade300),
      backgroundColor: Colors.grey.shade50,
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
