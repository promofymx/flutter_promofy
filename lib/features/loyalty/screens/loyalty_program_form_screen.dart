import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promofy/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/loyalty_cubit.dart';
import '../cubit/loyalty_state.dart';

/// Formulario para crear un nuevo programa de lealtad.
class LoyaltyProgramFormScreen extends StatefulWidget {
  const LoyaltyProgramFormScreen({super.key});

  @override
  State<LoyaltyProgramFormScreen> createState() =>
      _LoyaltyProgramFormScreenState();
}

class _LoyaltyProgramFormScreenState extends State<LoyaltyProgramFormScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _visitsCtrl       = TextEditingController(text: '5');
  final _rewardCtrl       = TextEditingController();
  DateTime _startsAt      = DateTime.now();
  DateTime? _endsAt;
  bool _saving            = false;

  // ── Reglas (opcionales) ──
  bool _onePerDay         = false;
  final _minTicketCtrl    = TextEditingController();   // vacío/0 = sin regla
  final _minHoursCtrl     = TextEditingController();
  final _stampDaysCtrl    = TextEditingController();
  final _rewardDaysCtrl   = TextEditingController();

  @override
  void dispose() {
    _visitsCtrl.dispose();
    _rewardCtrl.dispose();
    _minTicketCtrl.dispose();
    _minHoursCtrl.dispose();
    _stampDaysCtrl.dispose();
    _rewardDaysCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isEnd}) async {
    final now   = DateTime.now();
    final first = isEnd ? _startsAt.add(const Duration(days: 1)) : now;
    final initial = isEnd
        ? (_endsAt ?? first)
        : _startsAt;

    final picked = await showDatePicker(
      context:      context,
      initialDate:  initial.isBefore(first) ? first : initial,
      firstDate:    first,
      lastDate:     DateTime(now.year + 3),
      locale:       const Locale('es', 'MX'),
    );
    if (picked == null) return;
    setState(() {
      if (isEnd) {
        _endsAt = picked;
      } else {
        _startsAt = picked;
        // Si el fin ya está antes del nuevo inicio, lo limpiamos
        if (_endsAt != null && !_endsAt!.isAfter(_startsAt)) {
          _endsAt = null;
        }
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_endsAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  Text(AppLocalizations.of(context).loyaltyFormSelectEndDate),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _saving = true);

    final ok = await context.read<LoyaltyCubit>().createProgram(
      visitsRequired:    int.parse(_visitsCtrl.text.trim()),
      rewardDescription: _rewardCtrl.text.trim(),
      startsAt:          _startsAt,
      endsAt:            _endsAt!,
      onePerDay:          _onePerDay,
      minTicketMxn:       double.tryParse(_minTicketCtrl.text.trim()) ?? 0,
      minHoursBetween:    int.tryParse(_minHoursCtrl.text.trim()) ?? 0,
      stampValidityDays:  int.tryParse(_stampDaysCtrl.text.trim()) ?? 0,
      rewardValidityDays: int.tryParse(_rewardDaysCtrl.text.trim()) ?? 0,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text(AppLocalizations.of(context).loyaltyFormCreateError),
          backgroundColor: Colors.red,
          behavior:        SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoyaltyCubit, LoyaltyState>(
      listener: (_, __) {},
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context).loyaltyFormTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Explicación ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:        AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(color: AppColors.primary.withAlpha(40)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).loyaltyFormInfo,
                        style: const TextStyle(
                            fontSize: 13,
                            color:    AppColors.primary,
                            height:   1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Visitas requeridas ────────────────────────────────
              Text(
                AppLocalizations.of(context).loyaltyFormVisitsLabel,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller:   _visitsCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: InputDecoration(
                  hintText:    AppLocalizations.of(context).loyaltyFormVisitsHint,
                  prefixIcon:  const Icon(Icons.confirmation_number_outlined),
                  suffixText:  AppLocalizations.of(context).loyaltyFormVisitsSuffix,
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 2) {
                    return AppLocalizations.of(context).loyaltyFormVisitsMin;
                  }
                  if (n > 50) return AppLocalizations.of(context).loyaltyFormVisitsMax;
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Premio ────────────────────────────────────────────
              Text(
                AppLocalizations.of(context).loyaltyFormRewardLabel,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller:  _rewardCtrl,
                maxLength:   120,
                maxLines:    2,
                decoration: InputDecoration(
                  hintText:   AppLocalizations.of(context).loyaltyFormRewardHint,
                  prefixIcon: const Icon(Icons.card_giftcard_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return AppLocalizations.of(context).loyaltyFormRewardRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Fechas ────────────────────────────────────────────
              Text(
                AppLocalizations.of(context).loyaltyFormValidityLabel,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DateButton(
                      label:    AppLocalizations.of(context).loyaltyFormStartLabel,
                      date:     _startsAt,
                      icon:     Icons.calendar_today_outlined,
                      onTap:    () => _pickDate(isEnd: false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateButton(
                      label:   AppLocalizations.of(context).loyaltyFormEndLabel,
                      date:    _endsAt,
                      icon:    Icons.event_outlined,
                      onTap:   () => _pickDate(isEnd: true),
                      isEmpty: _endsAt == null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Reglas (opcionales) ───────────────────────────────
              Row(
                children: [
                  const Icon(Icons.tune, size: 18, color: AppColors.textDark),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).loyaltyRulesTitle,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context).loyaltyRulesSubtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
              ),
              const SizedBox(height: 12),

              // Máx 1 sello por día
              SwitchListTile.adaptive(
                value: _onePerDay,
                onChanged: (v) => setState(() => _onePerDay = v),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: Text(
                  AppLocalizations.of(context).loyaltyRuleOnePerDay,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              const Divider(height: 8),
              const SizedBox(height: 8),

              // Consumo mínimo
              _RuleNumberField(
                controller: _minTicketCtrl,
                label:      AppLocalizations.of(context).loyaltyRuleMinTicket,
                hint:       AppLocalizations.of(context).loyaltyRuleOffHint,
                icon:       Icons.attach_money,
                prefix:     '\$',
                decimals:   true,
              ),
              const SizedBox(height: 12),

              // Horas entre sellos
              _RuleNumberField(
                controller: _minHoursCtrl,
                label:      AppLocalizations.of(context).loyaltyRuleMinHours,
                hint:       AppLocalizations.of(context).loyaltyRuleOffHint,
                icon:       Icons.schedule,
                suffix:     AppLocalizations.of(context).loyaltyRuleHoursSuffix,
              ),
              const SizedBox(height: 12),

              // Vigencia de sellos
              _RuleNumberField(
                controller: _stampDaysCtrl,
                label:      AppLocalizations.of(context).loyaltyRuleStampValidity,
                hint:       AppLocalizations.of(context).loyaltyRuleOffHint,
                icon:       Icons.timelapse,
                suffix:     AppLocalizations.of(context).loyaltyRuleDaysSuffix,
              ),
              const SizedBox(height: 12),

              // Vigencia de recompensa
              _RuleNumberField(
                controller: _rewardDaysCtrl,
                label:      AppLocalizations.of(context).loyaltyRuleRewardValidity,
                hint:       AppLocalizations.of(context).loyaltyRuleOffHint,
                icon:       Icons.hourglass_bottom,
                suffix:     AppLocalizations.of(context).loyaltyRuleDaysSuffix,
              ),

              const SizedBox(height: 32),

              // ── Botón ─────────────────────────────────────────────
              ElevatedButton.icon(
                onPressed: _saving ? null : _submit,
                icon:  _saving
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.rocket_launch_outlined),
                label: Text(
                  _saving
                      ? AppLocalizations.of(context).loyaltyFormSaving
                      : AppLocalizations.of(context).loyaltyFormSubmit,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Campo numérico para una regla (vacío/0 = regla apagada).
class _RuleNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String   label;
  final String   hint;
  final IconData icon;
  final String?  prefix;
  final String?  suffix;
  final bool     decimals;

  const _RuleNumberField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.prefix,
    this.suffix,
    this.decimals = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller:   controller,
          keyboardType: TextInputType.numberWithOptions(decimal: decimals),
          inputFormatters: [
            decimals
                ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                : FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText:   hint,
            prefixIcon: Icon(icon, size: 20),
            prefixText: prefix,
            suffixText: suffix,
            isDense:    true,
          ),
        ),
      ],
    );
  }
}

class _DateButton extends StatelessWidget {
  final String    label;
  final DateTime? date;
  final IconData  icon;
  final VoidCallback onTap;
  final bool      isEmpty;

  static final _fmt = DateFormat('dd/MM/yyyy', 'es_MX');

  const _DateButton({
    required this.label,
    required this.date,
    required this.icon,
    required this.onTap,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color:  Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmpty ? Colors.grey.shade300 : AppColors.primary.withAlpha(80),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size:  18,
                color: isEmpty ? Colors.grey.shade400 : AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                        fontSize: 11,
                        color:    Colors.grey.shade500),
                  ),
                  Text(
                    date != null
                        ? _fmt.format(date!)
                        : AppLocalizations.of(context).loyaltyFormSelectDate,
                    style: TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w500,
                      color: isEmpty
                          ? Colors.grey.shade400
                          : AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
