import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promofy/l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _gender;

  @override
  void initState() {
    super.initState();
    // Prefill del nombre cuando el proveedor (Apple/Google) ya lo dio, para no
    // pedirlo de nuevo (Apple guideline 4 — Sign in with Apple).
    final meta = supabase.auth.currentUser?.userMetadata;
    final name = (meta?['full_name'] ?? meta?['name']) as String?;
    if (name != null && name.trim().isNotEmpty) {
      _nameController.text = name.trim();
    }
    _prefillFromProfile();
  }

  /// Respaldo: si la metadata no traía nombre (p. ej. Apple lo guardó en el
  /// perfil), lo tomamos de la tabla profiles.
  Future<void> _prefillFromProfile() async {
    if (_nameController.text.trim().isNotEmpty) return;
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final row = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', uid)
          .maybeSingle();
      final n = row?['full_name'] as String?;
      if (n != null && n.trim().isNotEmpty && mounted) {
        setState(() => _nameController.text = n.trim());
      }
    } catch (_) {/* no crítico */}
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    // lastDate = exactamente 18 años atrás (cuenta día y mes, no solo año)
    final maxDate = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: maxDate,
      helpText: AppLocalizations.of(context).onboardingMustBeAdult,
      confirmText: AppLocalizations.of(context).onboardingConfirm,
      cancelText: AppLocalizations.of(context).onboardingCancel,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _submit(BuildContext context) {
    // Nombre, fecha y género son OPCIONALES (Apple 5.1.1 / 4.0).
    // Si SÍ eligió fecha, validamos mayoría de edad (el picker ya limita a +18).
    if (_birthDate != null) {
      final today  = DateTime.now();
      final minAge = DateTime(today.year - 18, today.month, today.day);
      if (_birthDate!.isAfter(minAge)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).onboardingMustBeAdultToUse),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    final name = _nameController.text.trim();
    context.read<AuthBloc>().add(AuthOnboardingCompleted(
          fullName:  name.isEmpty ? null : name,
          birthDate: _birthDate,
          gender:    _gender,
        ));
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).onboardingTitle),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: AppLocalizations.of(context).onboardingExit,
          onPressed: () =>
              context.read<AuthBloc>().add(AuthSignOutRequested()),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.primary),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).onboardingHeading,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context).onboardingAdultOnlyNotice,
                      style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                  const SizedBox(height: 36),

                  // Nombre
                  Text(AppLocalizations.of(context).onboardingNameQuestion,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).onboardingNameHint,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Fecha de nacimiento
                  Text(AppLocalizations.of(context).onboardingBirthQuestion,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            _birthDate != null
                                ? _formatDate(_birthDate!)
                                : AppLocalizations.of(context).onboardingSelectBirthDate,
                            style: TextStyle(
                              color: _birthDate != null
                                  ? AppColors.textDark
                                  : Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Género
                  Text(AppLocalizations.of(context).onboardingGenderQuestion,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _GenderOption(
                          label: AppLocalizations.of(context).onboardingGenderMale,
                          icon: Icons.male,
                          selected: _gender == 'male',
                          onTap: () => setState(() => _gender = 'male'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GenderOption(
                          label: AppLocalizations.of(context).onboardingGenderFemale,
                          icon: Icons.female,
                          selected: _gender == 'female',
                          onTap: () => setState(() => _gender = 'female'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _GenderOption(
                    label: AppLocalizations.of(context).onboardingGenderPreferNot,
                    icon: Icons.person_outline,
                    selected: _gender == 'prefer_not_to_say',
                    onTap: () =>
                        setState(() => _gender = 'prefer_not_to_say'),
                    fullWidth: true,
                  ),

                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: isLoading ? null : () => _submit(context),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(AppLocalizations.of(context).onboardingSubmit,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool fullWidth;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withAlpha(26)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                selected ? AppColors.primary : const Color(0xFFE0E0E0),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : Colors.grey,
                size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textDark,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}