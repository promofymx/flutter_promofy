import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:promofy/l10n/app_localizations.dart';
import '../../../core/constants/api_keys.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/characteristic_model.dart';
import '../../../data/models/establishment_model.dart';
import '../../../data/repositories/categories_repository.dart';
import '../../../main.dart' show supabase;
import '../cubit/business_cubit.dart';
import '../cubit/business_state.dart';

// ─── Helpers de localización ─────────────────────────────────────────────────

String _localizedStepLabel(BuildContext context, int index) {
  final l = AppLocalizations.of(context);
  switch (index) {
    case 0:
      return l.regBizStepBasic;
    case 1:
      return l.regBizStepType;
    default:
      return l.regBizStepSchedule;
  }
}

String _localizedDayLabel(BuildContext context, String dayKey) {
  final l = AppLocalizations.of(context);
  switch (dayKey) {
    case 'monday':
      return l.regBizDayMonday;
    case 'tuesday':
      return l.regBizDayTuesday;
    case 'wednesday':
      return l.regBizDayWednesday;
    case 'thursday':
      return l.regBizDayThursday;
    case 'friday':
      return l.regBizDayFriday;
    case 'saturday':
      return l.regBizDaySaturday;
    default:
      return l.regBizDaySunday;
  }
}

// ─── Modelos internos ────────────────────────────────────────────────────────

class _AddressResult {
  final String formattedAddress;
  final double lat;
  final double lng;
  const _AddressResult({required this.formattedAddress, required this.lat, required this.lng});
}

class _PlacePrediction {
  final String placeId;
  final String description;
  _PlacePrediction({required this.placeId, required this.description});
}

/// Horario de un día de la semana.
class _DaySchedule {
  final bool      closed;
  final TimeOfDay open;
  final TimeOfDay close;

  const _DaySchedule({
    this.closed = false,
    this.open   = const TimeOfDay(hour: 9,  minute: 0),
    this.close  = const TimeOfDay(hour: 22, minute: 0),
  });

  _DaySchedule copyWith({bool? closed, TimeOfDay? open, TimeOfDay? close}) =>
      _DaySchedule(
        closed: closed ?? this.closed,
        open:   open   ?? this.open,
        close:  close  ?? this.close,
      );

  Map<String, dynamic> toJson() => closed
      ? {'closed': true}
      : {
          'closed': false,
          'open':  _fmt(open),
          'close': _fmt(close),
        };

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  factory _DaySchedule.fromJson(Map<String, dynamic> json) {
    if (json['closed'] == true) return const _DaySchedule(closed: true);
    final op = (json['open']  as String? ?? '09:00').split(':');
    final cl = (json['close'] as String? ?? '22:00').split(':');
    return _DaySchedule(
      open:  TimeOfDay(hour: int.parse(op[0]), minute: int.parse(op[1])),
      close: TimeOfDay(hour: int.parse(cl[0]), minute: int.parse(cl[1])),
    );
  }
}

// ─── Pantalla principal (wizard) ─────────────────────────────────────────────

class RegisterBusinessScreen extends StatefulWidget {
  final EstablishmentModel? establishment;
  const RegisterBusinessScreen({super.key, this.establishment});

  @override
  State<RegisterBusinessScreen> createState() => _RegisterBusinessScreenState();
}

class _RegisterBusinessScreenState extends State<RegisterBusinessScreen> {

  // ── Navegación ────────────────────────────────────────────────────────────
  final _pageCtrl    = PageController();
  int   _currentStep = 0;
  static const _totalSteps = 3;
  static const _stepLabels = ['Datos básicos', 'Tipo y categoría', 'Horario y extras'];

  // ── Paso 1 ────────────────────────────────────────────────────────────────
  final _formKey1           = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _facebookCtrl;
  late final TextEditingController _instagramCtrl;
  late final TextEditingController _websiteCtrl;
  _AddressResult? _selectedAddress;

  // ── Paso 2 ────────────────────────────────────────────────────────────────
  String?    _estType;                          // 'local' | 'urban_mobile'
  final Set<int> _selectedCatIds = {};          // multi-select categorías
  bool       _adultPromos = false;

  // ── Paso 3 ────────────────────────────────────────────────────────────────
  static const _dayKeys = [
    'monday','tuesday','wednesday','thursday','friday','saturday','sunday',
  ];
  static const _dayLabels = [
    'Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo',
  ];
  static const _paymentOptions = <(String, String)>[
    ('card',  'Tarjeta crédito/débito'),
    ('cash',  'Efectivo'),
    ('other', 'Otro'),
  ];

  late final Map<String, _DaySchedule> _schedule;
  final List<String> _selectedCharIds = [];
  final List<String> _selectedPayments = [];

  // ── Catálogos ─────────────────────────────────────────────────────────────
  List<CategoryModel>      _categories     = [];
  List<CharacteristicModel> _characteristics = [];
  bool _catalogsLoading = true;

  bool get _isEditing => widget.establishment != null;

  void _toggleCat(int id) {
    setState(() {
      if (_selectedCatIds.contains(id)) {
        _selectedCatIds.remove(id);
        // Deseleccionar hijos si se quita el padre
        final childIds = _categories
            .where((c) => c.parentId == id.toString())
            .map((c) => int.tryParse(c.id))
            .whereType<int>()
            .toSet();
        _selectedCatIds.removeAll(childIds);
        for (final child in childIds) {
          final grandChildIds = _categories
              .where((c) => c.parentId == child.toString())
              .map((c) => int.tryParse(c.id))
              .whereType<int>()
              .toSet();
          _selectedCatIds.removeAll(grandChildIds);
        }
      } else {
        _selectedCatIds.add(id);
      }
    });
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final est = widget.establishment;

    _nameCtrl      = TextEditingController(text: est?.name         ?? '');
    _descCtrl      = TextEditingController(text: est?.description  ?? '');
    _addressCtrl   = TextEditingController(text: est?.address      ?? '');
    _phoneCtrl     = TextEditingController(text: est?.phone        ?? '');
    _facebookCtrl  = TextEditingController(text: est?.facebookUrl  ?? '');
    _instagramCtrl = TextEditingController(text: est?.instagramUrl ?? '');
    _websiteCtrl   = TextEditingController(text: est?.website      ?? '');

    if (est != null && est.lat != null && est.lng != null) {
      _selectedAddress = _AddressResult(
        formattedAddress: est.address ?? '',
        lat: est.lat!,
        lng: est.lng!,
      );
    }

    _estType     = est?.establishmentType;
    _adultPromos = est?.adultPromotions ?? false;

    if (est?.paymentMethods != null) {
      _selectedPayments.addAll(est!.paymentMethods);
    }

    // Horario — inicializa con defaults (domingo cerrado por defecto)
    _schedule = {
      for (int i = 0; i < _dayKeys.length; i++)
        _dayKeys[i]: (est?.schedule != null && est!.schedule!.containsKey(_dayKeys[i]))
            ? _DaySchedule.fromJson(est.schedule![_dayKeys[i]] as Map<String, dynamic>)
            : _DaySchedule(closed: _dayKeys[i] == 'sunday'),
    };

    _loadCatalogs();
  }

  Future<void> _loadCatalogs() async {
    try {
      final repo    = CategoriesRepository();
      final results = await Future.wait([
        repo.getCategories(),
        repo.getCharacteristics(),
      ]);
      setState(() {
        _categories      = results[0] as List<CategoryModel>;
        _characteristics = results[1] as List<CharacteristicModel>;
        _catalogsLoading = false;
      });
      _prefillEditData();
    } catch (_) {
      setState(() => _catalogsLoading = false);
    }
  }

  void _prefillEditData() {
    final est = widget.establishment;
    if (est == null) return;

    // Características previas
    final charIds = est.characteristics.map((c) => c.id).toList();
    if (charIds.isNotEmpty) {
      setState(() => _selectedCharIds.addAll(charIds));
    }

    // Categorías previas — preferir categoryIds[], fallback a categoryId
    final catIds = est.categoryIds.isNotEmpty
        ? est.categoryIds
        : (est.categoryId != null ? [est.categoryId!] : <int>[]);
    if (catIds.isNotEmpty) {
      setState(() => _selectedCatIds.addAll(catIds));
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();     _descCtrl.dispose();
    _addressCtrl.dispose();  _phoneCtrl.dispose();
    _facebookCtrl.dispose(); _instagramCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  // ── Navegación entre pasos ────────────────────────────────────────────────

  void _next() {
    if (_currentStep == 0) {
      if (!(_formKey1.currentState?.validate() ?? false)) return;
      if (!_isEditing && _selectedAddress == null) {
        _snack(AppLocalizations.of(context).regBizSelectAddressHint);
        return;
      }
    }
    if (_currentStep == 1) {
      if (_estType == null) {
        _snack(AppLocalizations.of(context).regBizSelectType);
        return;
      }
      if (_selectedCatIds.isEmpty) {
        _snack(AppLocalizations.of(context).regBizSelectCategory);
        return;
      }
    }
    if (_currentStep == 2) {
      if (_selectedCharIds.isEmpty) {
        _snack(AppLocalizations.of(context).regBizSelectCharacteristic);
        return;
      }
      if (_selectedPayments.isEmpty) {
        _snack(AppLocalizations.of(context).regBizSelectPayment);
        return;
      }
      if (_schedule.values.every((d) => d.closed)) {
        _snack(AppLocalizations.of(context).regBizSelectDay);
        return;
      }
      _save();
      return;
    }
    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 300),
      curve:    Curves.easeInOut,
    );
    setState(() => _currentStep++);
  }

  void _back() {
    if (_currentStep == 0) { Navigator.of(context).pop(); return; }
    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 300),
      curve:    Curves.easeInOut,
    );
    setState(() => _currentStep--);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // ── Guardar ───────────────────────────────────────────────────────────────

  void _save() {
    final lat     = _selectedAddress?.lat ?? widget.establishment?.lat;
    final lng     = _selectedAddress?.lng ?? widget.establishment?.lng;
    final address = _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim();
    final scheduleJson = { for (int i = 0; i < _dayKeys.length; i++)
      _dayKeys[i]: _schedule[_dayKeys[i]]!.toJson() };

    String? nullIfEmpty(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();

    final cubit = context.read<BusinessCubit>();

    final catIdsList = _selectedCatIds.toList();

    if (_isEditing) {
      cubit.update(
        id:                widget.establishment!.id,
        name:              _nameCtrl.text.trim(),
        description:       nullIfEmpty(_descCtrl),
        address:           address,
        phone:             nullIfEmpty(_phoneCtrl),
        website:           nullIfEmpty(_websiteCtrl),
        lat:               lat,
        lng:               lng,
        categoryId:        catIdsList.isNotEmpty ? catIdsList.first : null,
        categoryIds:       catIdsList,
        establishmentType: _estType,
        schedule:          scheduleJson,
        paymentMethods:    List.from(_selectedPayments),
        adultPromotions:   _adultPromos,
        facebookUrl:       nullIfEmpty(_facebookCtrl),
        instagramUrl:      nullIfEmpty(_instagramCtrl),
        characteristicIds: List.from(_selectedCharIds),
      );
    } else {
      cubit.create(
        name:              _nameCtrl.text.trim(),
        description:       nullIfEmpty(_descCtrl),
        address:           address,
        phone:             nullIfEmpty(_phoneCtrl),
        website:           nullIfEmpty(_websiteCtrl),
        lat:               lat!,
        lng:               lng!,
        categoryId:        catIdsList.isNotEmpty ? catIdsList.first : null,
        categoryIds:       catIdsList,
        establishmentType: _estType,
        schedule:          scheduleJson,
        paymentMethods:    List.from(_selectedPayments),
        adultPromotions:   _adultPromos,
        facebookUrl:       nullIfEmpty(_facebookCtrl),
        instagramUrl:      nullIfEmpty(_instagramCtrl),
        characteristicIds: List.from(_selectedCharIds),
      );
    }
  }

  // ── Buscador de dirección ─────────────────────────────────────────────────

  Future<void> _openAddressSearch() async {
    await showModalBottomSheet<void>(
      context:           context,
      isScrollControlled: true,
      useSafeArea:        true,
      backgroundColor:    Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _AddressSearchSheet(
        onSelected: (result) {
          setState(() {
            _selectedAddress        = result;
            _addressCtrl.text       = result.formattedAddress;
          });
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusinessCubit, BusinessState>(
      listenWhen: (p, c) => p is BusinessSaving,
      listener: (context, state) {
        if (state is BusinessLoaded) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing
                  ? AppLocalizations.of(context).regBizUpdatedOk
                  : AppLocalizations.of(context).regBizCreatedOk),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is BusinessError) {
          _snack(state.message);
          context.read<BusinessCubit>().clearError();
        }
      },
      builder: (context, state) {
        final isSaving = state is BusinessSaving;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: isSaving ? null : _back,
            ),
            title: Text(
              _isEditing
                  ? AppLocalizations.of(context).regBizEditTitle
                  : AppLocalizations.of(context).regBizCreateTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: _StepIndicator(
                current: _currentStep,
                total:   _totalSteps,
                labels:  _stepLabels,
              ),
            ),
          ),
          body: _catalogsLoading
              ? const Center(child: CircularProgressIndicator())
              : PageView(
                  controller: _pageCtrl,
                  physics:    const NeverScrollableScrollPhysics(),
                  children: [
                    // ── Paso 1 ───────────────────────────────────────────
                    _Step1BasicData(
                      formKey:        _formKey1,
                      nameCtrl:       _nameCtrl,
                      descCtrl:       _descCtrl,
                      addressCtrl:    _addressCtrl,
                      phoneCtrl:      _phoneCtrl,
                      facebookCtrl:   _facebookCtrl,
                      instagramCtrl:  _instagramCtrl,
                      websiteCtrl:    _websiteCtrl,
                      isEditing:      _isEditing,
                      onAddressTap:   _openAddressSearch,
                      onAddressClear: () => setState(() {
                        _addressCtrl.clear();
                        _selectedAddress = null;
                      }),
                    ),
                    // ── Paso 2 ───────────────────────────────────────────
                    _Step2TypeCategory(
                      categories:          _categories,
                      estType:             _estType,
                      selectedCatIds:      _selectedCatIds,
                      adultPromos:         _adultPromos,
                      onTypeChanged:       (t) => setState(() => _estType = t),
                      onToggleCat:         _toggleCat,
                      onAdultPromoChanged: (v) => setState(() => _adultPromos = v),
                    ),
                    // ── Paso 3 ───────────────────────────────────────────
                    _Step3ScheduleExtras(
                      dayKeys:        _dayKeys,
                      dayLabels:      _dayLabels,
                      schedule:       _schedule,
                      characteristics: _characteristics,
                      selectedCharIds: _selectedCharIds,
                      paymentOptions:  _paymentOptions,
                      selectedPayments: _selectedPayments,
                      onScheduleChanged: (day, s) =>
                          setState(() => _schedule[day] = s),
                      onCharToggled: (id) => setState(() {
                        _selectedCharIds.contains(id)
                            ? _selectedCharIds.remove(id)
                            : _selectedCharIds.add(id);
                      }),
                      onPaymentToggled: (key) => setState(() {
                        _selectedPayments.contains(key)
                            ? _selectedPayments.remove(key)
                            : _selectedPayments.add(key);
                      }),
                    ),
                  ],
                ),

          // ── Botones de navegación ────────────────────────────────────────
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSaving ? null : _back,
                        style: OutlinedButton.styleFrom(
                          minimumSize:     const Size(0, 52),
                          side:            const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(AppLocalizations.of(context).regBizBack),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _next,
                      child: isSaving
                          ? const SizedBox(
                              height: 22, width: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : Text(
                              _currentStep == _totalSteps - 1
                                  ? (_isEditing
                                      ? AppLocalizations.of(context).regBizSaveChanges
                                      : AppLocalizations.of(context).regBizCreateTitle)
                                  : AppLocalizations.of(context).regBizNext,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Indicador de paso ───────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  final List<String> labels;

  const _StepIndicator({
    required this.current,
    required this.total,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(
          value:           (current + 1) / total,
          backgroundColor: Colors.grey.shade200,
          color:           AppColors.primary,
          minHeight:       3,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).regBizStepOf(current + 1, total),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                _localizedStepLabel(context, current),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Paso 1 — Datos básicos ──────────────────────────────────────────────────

class _Step1BasicData extends StatelessWidget {
  final GlobalKey<FormState>  formKey;
  final TextEditingController nameCtrl, descCtrl, addressCtrl,
                               phoneCtrl, facebookCtrl, instagramCtrl, websiteCtrl;
  final bool          isEditing;
  final VoidCallback  onAddressTap;
  final VoidCallback  onAddressClear;

  const _Step1BasicData({
    required this.formKey,
    required this.nameCtrl,
    required this.descCtrl,
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.facebookCtrl,
    required this.instagramCtrl,
    required this.websiteCtrl,
    required this.isEditing,
    required this.onAddressTap,
    required this.onAddressClear,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Información principal ──────────────────────────────────
            _SectionHeader(title: AppLocalizations.of(context).regBizSectionMain),
            const SizedBox(height: 12),

            _FieldLabel(text: AppLocalizations.of(context).regBizNameLabel),
            const SizedBox(height: 6),
            TextFormField(
              controller:          nameCtrl,
              textCapitalization:  TextCapitalization.words,
              decoration: InputDecoration(
                hintText:   AppLocalizations.of(context).regBizNameHint,
                prefixIcon: const Icon(Icons.store_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppLocalizations.of(context).regBizNameRequired
                  : null,
            ),
            const SizedBox(height: 16),

            _FieldLabel(text: AppLocalizations.of(context).regBizDescLabel),
            const SizedBox(height: 6),
            TextFormField(
              controller:         descCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines:  3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText:  AppLocalizations.of(context).regBizDescHint,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child:   Icon(Icons.notes_outlined),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),

            // ── Ubicación ──────────────────────────────────────────────
            _SectionHeader(title: AppLocalizations.of(context).regBizSectionLocation),
            const SizedBox(height: 12),

            _FieldLabel(text: isEditing
                ? AppLocalizations.of(context).regBizAddressLabel
                : AppLocalizations.of(context).regBizAddressLabelRequired),
            const SizedBox(height: 6),
            Stack(
              alignment: Alignment.centerRight,
              children: [
                GestureDetector(
                  onTap: onAddressTap,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: addressCtrl,
                      decoration: InputDecoration(
                        hintText:   AppLocalizations.of(context).regBizAddressHint,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        suffixIcon: addressCtrl.text.isNotEmpty
                            ? const SizedBox(width: 48)
                            : const Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                if (addressCtrl.text.isNotEmpty)
                  Positioned(
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                      onPressed: onAddressClear,
                    ),
                  ),
              ],
            ),
            if (!isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  AppLocalizations.of(context).regBizAddressHelper,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            const SizedBox(height: 24),

            // ── Contacto ───────────────────────────────────────────────
            _SectionHeader(title: AppLocalizations.of(context).regBizSectionContact),
            const SizedBox(height: 12),

            _FieldLabel(text: AppLocalizations.of(context).regBizPhoneLabel),
            const SizedBox(height: 6),
            TextFormField(
              controller:   phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText:   AppLocalizations.of(context).regBizPhoneHint,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 24),

            // ── Redes sociales ─────────────────────────────────────────
            _SectionHeader(title: AppLocalizations.of(context).regBizSectionSocial),
            const SizedBox(height: 12),

            const _FieldLabel(text: 'Facebook'),
            const SizedBox(height: 6),
            TextFormField(
              controller:   facebookCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText:   'https://facebook.com/tunegocio',
                prefixIcon: Icon(Icons.facebook_outlined),
              ),
            ),
            const SizedBox(height: 16),

            const _FieldLabel(text: 'Instagram'),
            const SizedBox(height: 6),
            TextFormField(
              controller:   instagramCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText:   'https://instagram.com/tunegocio',
                prefixIcon: Icon(Icons.camera_alt_outlined),
              ),
            ),
            const SizedBox(height: 16),

            _FieldLabel(text: AppLocalizations.of(context).regBizWebsiteLabel),
            const SizedBox(height: 6),
            TextFormField(
              controller:   websiteCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText:   'https://tunegocio.com',
                prefixIcon: Icon(Icons.language_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Paso 2 — Tipo y categoría ───────────────────────────────────────────────

class _Step2TypeCategory extends StatelessWidget {
  final List<CategoryModel> categories;
  final String?        estType;
  final Set<int>       selectedCatIds;
  final bool           adultPromos;
  final void Function(String) onTypeChanged;
  final void Function(int)    onToggleCat;
  final void Function(bool)   onAdultPromoChanged;

  const _Step2TypeCategory({
    required this.categories,
    required this.estType,
    required this.selectedCatIds,
    required this.adultPromos,
    required this.onTypeChanged,
    required this.onToggleCat,
    required this.onAdultPromoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l1Cats = categories.where((c) => c.parentId == null).toList();
    // L2: hijos de cualquier L1 seleccionado
    final l2Cats = categories.where((c) =>
        c.parentId != null &&
        selectedCatIds.contains(int.tryParse(c.parentId!)) &&
        l1Cats.any((l1) => l1.id == c.parentId)).toList();
    // L3: hijos de cualquier L2 seleccionado
    final l3Cats = categories.where((c) =>
        c.parentId != null &&
        selectedCatIds.contains(int.tryParse(c.parentId!)) &&
        l2Cats.any((l2) => l2.id == c.parentId)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tipo de establecimiento ────────────────────────────────
          _SectionHeader(title: AppLocalizations.of(context).regBizTypeSection),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TypeCard(
                  icon:     Icons.storefront_outlined,
                  label:    AppLocalizations.of(context).regBizTypeLocal,
                  subtitle: AppLocalizations.of(context).regBizTypeLocalSub,
                  selected: estType == 'local',
                  onTap:    () => onTypeChanged('local'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TypeCard(
                  icon:     Icons.directions_car_outlined,
                  label:    AppLocalizations.of(context).regBizTypeMobile,
                  subtitle: AppLocalizations.of(context).regBizTypeMobileSub,
                  selected: estType == 'urban_mobile',
                  onTap:    () => onTypeChanged('urban_mobile'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Categoría ──────────────────────────────────────────────
          _SectionHeader(title: AppLocalizations.of(context).regBizCategorySection),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context).regBizCategoryHelper,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 12),

          // Nivel 1 — multi-select
          _ChipGroup(
            label:       '',
            items:       l1Cats,
            selectedIds: selectedCatIds,
            color:       AppColors.primary,
            onTap:       onToggleCat,
          ),

          // Nivel 2 — opcional, multi-select
          if (l2Cats.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ChipGroup(
              label:       AppLocalizations.of(context).regBizSubcategoryLabel,
              items:       l2Cats,
              selectedIds: selectedCatIds,
              color:       AppColors.secondary,
              onTap:       onToggleCat,
            ),
          ],

          // Nivel 3 — opcional, multi-select
          if (l3Cats.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ChipGroup(
              label:       AppLocalizations.of(context).regBizSpecialtyLabel,
              items:       l3Cats,
              selectedIds: selectedCatIds,
              color:       AppColors.primary,
              onTap:       onToggleCat,
            ),
          ],

          const SizedBox(height: 24),

          // ── Información adicional ──────────────────────────────────
          _SectionHeader(title: AppLocalizations.of(context).regBizExtraSection),
          const SizedBox(height: 4),
          SwitchListTile.adaptive(
            value:       adultPromos,
            onChanged:   onAdultPromoChanged,
            activeColor: AppColors.primary,
            title: Text(
              AppLocalizations.of(context).regBizAdultPromos,
              style: const TextStyle(fontSize: 14),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

// ─── Paso 3 — Horario y extras ───────────────────────────────────────────────

class _Step3ScheduleExtras extends StatelessWidget {
  final List<String>           dayKeys;
  final List<String>           dayLabels;
  final Map<String, _DaySchedule> schedule;
  final List<CharacteristicModel> characteristics;
  final List<String>           selectedCharIds;
  final List<(String, String)> paymentOptions;
  final List<String>           selectedPayments;
  final void Function(String, _DaySchedule) onScheduleChanged;
  final void Function(String)  onCharToggled;
  final void Function(String)  onPaymentToggled;

  const _Step3ScheduleExtras({
    required this.dayKeys,
    required this.dayLabels,
    required this.schedule,
    required this.characteristics,
    required this.selectedCharIds,
    required this.paymentOptions,
    required this.selectedPayments,
    required this.onScheduleChanged,
    required this.onCharToggled,
    required this.onPaymentToggled,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Horario ────────────────────────────────────────────────
          _SectionHeader(title: AppLocalizations.of(context).regBizScheduleSection),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context).regBizScheduleHelper,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withAlpha(10),
                  blurRadius: 6,
                  offset:     const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              children: [
                for (int i = 0; i < dayKeys.length; i++)
                  _DayRow(
                    label:    _localizedDayLabel(context, dayKeys[i]),
                    schedule: schedule[dayKeys[i]]!,
                    onChanged: (s) => onScheduleChanged(dayKeys[i], s),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Características ────────────────────────────────────────
          _SectionHeader(title: AppLocalizations.of(context).regBizCharSection),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context).regBizCharHelper,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: characteristics.map((c) {
              final selected = selectedCharIds.contains(c.id);
              return FilterChip(
                label:          Text(c.localizedName(Localizations.localeOf(context).languageCode)),
                selected:       selected,
                selectedColor:  AppColors.primary.withAlpha(30),
                checkmarkColor: AppColors.primary,
                side: BorderSide(
                  color: selected ? AppColors.primary : Colors.grey.shade300,
                ),
                labelStyle: TextStyle(
                  fontSize:   13,
                  color:      selected ? AppColors.primary : AppColors.textDark,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (_) => onCharToggled(c.id),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ── Métodos de pago ────────────────────────────────────────
          _SectionHeader(title: AppLocalizations.of(context).regBizPaymentSection),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: paymentOptions.map(((String, String) opt) {
              final (key, _) = opt;
              final selected     = selectedPayments.contains(key);
              final label = key == 'card'
                  ? AppLocalizations.of(context).regBizPaymentCard
                  : key == 'cash'
                      ? AppLocalizations.of(context).regBizPaymentCash
                      : AppLocalizations.of(context).regBizPaymentOther;
              return FilterChip(
                label:          Text(label),
                selected:       selected,
                selectedColor:  AppColors.secondary.withAlpha(30),
                checkmarkColor: AppColors.secondary,
                side: BorderSide(
                  color: selected ? AppColors.secondary : Colors.grey.shade300,
                ),
                labelStyle: TextStyle(
                  fontSize:   13,
                  color:      selected ? AppColors.secondary : AppColors.textDark,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (_) => onPaymentToggled(key),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Widget: fila de día en el horario ───────────────────────────────────────

class _DayRow extends StatelessWidget {
  final String       label;
  final _DaySchedule schedule;
  final void Function(_DaySchedule) onChanged;

  const _DayRow({
    required this.label,
    required this.schedule,
    required this.onChanged,
  });

  Future<void> _pickTime(BuildContext context, bool isOpen) async {
    final picked = await showTimePicker(
      context:     context,
      initialTime: isOpen ? schedule.open : schedule.close,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    onChanged(schedule.copyWith(
      open:  isOpen ? picked : null,
      close: isOpen ? null   : picked,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Switch.adaptive(
            value:       !schedule.closed,
            onChanged:   (v) => onChanged(schedule.copyWith(closed: !v)),
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          if (!schedule.closed) ...[
            const SizedBox(width: 4),
            _TimeChip(
              time:  schedule.open,
              onTap: () => _pickTime(context, true),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('–', style: TextStyle(color: Colors.grey)),
            ),
            _TimeChip(
              time:  schedule.close,
              onTap: () => _pickTime(context, false),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                AppLocalizations.of(context).regBizClosed,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final TimeOfDay  time;
  final VoidCallback onTap;

  const _TimeChip({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color:        AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border:       Border.all(color: AppColors.primary.withAlpha(70)),
        ),
        child: Text(
          '$h:$m',
          style: const TextStyle(
            fontSize:   13,
            color:      AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Widget: selector de tipo ────────────────────────────────────────────────

class _TypeCard extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final String       subtitle;
  final bool         selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        selected ? AppColors.primary.withAlpha(20) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
              color: selected ? AppColors.primary : Colors.grey.shade500,
              size:  28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widget: grupo de chips de categoría ─────────────────────────────────────

class _ChipGroup extends StatelessWidget {
  final String             label;
  final List<CategoryModel> items;
  final Set<int>           selectedIds;
  final Color              color;
  final void Function(int) onTap;

  const _ChipGroup({
    required this.label,
    required this.items,
    required this.selectedIds,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500,
                fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
        ],
        Wrap(
          spacing: 8, runSpacing: 8,
          children: items.map((cat) {
            final id       = int.tryParse(cat.id);
            final selected = id != null && selectedIds.contains(id);
            return FilterChip(
              label: Text(cat.localizedName(Localizations.localeOf(context).languageCode)),
              selected:       selected,
              selectedColor:  color.withAlpha(30),
              checkmarkColor: color,
              side: BorderSide(
                color: selected ? color : Colors.grey.shade300,
              ),
              labelStyle: TextStyle(
                fontSize:   13,
                color:      selected ? color : AppColors.textDark,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              onSelected: (_) { if (id != null) onTap(id); },
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Widgets auxiliares ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark),
    );
  }
}

// ─── Bottom sheet de búsqueda de dirección ───────────────────────────────────

class _AddressSearchSheet extends StatefulWidget {
  final void Function(_AddressResult) onSelected;
  const _AddressSearchSheet({required this.onSelected});

  @override
  State<_AddressSearchSheet> createState() => _AddressSearchSheetState();
}

class _AddressSearchSheetState extends State<_AddressSearchSheet> {
  final _controller = TextEditingController();
  Timer? _debounce;

  List<_PlacePrediction> _predictions = [];
  bool    _isLoading = false;
  String? _errorText;

  static const _autocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const _detailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';
  static const _edgeFunction = 'super-task';

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    if (text.trim().length < 3) {
      setState(() { _predictions = []; _errorText = null; });
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _fetchSuggestions(text.trim()),
    );
  }

  Future<void> _fetchSuggestions(String input) async {
    setState(() { _isLoading = true; _errorText = null; });
    try {
      final Map<String, dynamic> body;
      if (kIsWeb) {
        final res = await supabase.functions.invoke(
          _edgeFunction,
          body: {'type': 'autocomplete', 'input': input},
        );
        body = res.data as Map<String, dynamic>;
      } else {
        final uri = Uri.parse(_autocompleteUrl).replace(queryParameters: {
          'input': input, 'key': ApiKeys.googleMaps,
          'language': 'es', 'components': 'country:mx',
        });
        body = jsonDecode((await http.get(uri)).body) as Map<String, dynamic>;
      }

      if (body['status'] == 'OK') {
        setState(() {
          _predictions = (body['predictions'] as List).map((p) =>
              _PlacePrediction(
                placeId:     p['place_id'] as String,
                description: p['description'] as String,
              )).toList();
        });
      } else if (body['status'] == 'ZERO_RESULTS') {
        setState(() => _predictions = []);
      } else {
        setState(() => _errorText = AppLocalizations.of(context).regBizNoResults);
      }
    } catch (_) {
      setState(() => _errorText = AppLocalizations.of(context).regBizSearchError);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectPrediction(_PlacePrediction pred) async {
    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> body;
      if (kIsWeb) {
        final res = await supabase.functions.invoke(
          _edgeFunction,
          body: {'type': 'details', 'placeId': pred.placeId},
        );
        body = res.data as Map<String, dynamic>;
      } else {
        final uri = Uri.parse(_detailsUrl).replace(queryParameters: {
          'place_id': pred.placeId, 'key': ApiKeys.googleMaps,
          'fields': 'geometry,formatted_address', 'language': 'es',
        });
        body = jsonDecode((await http.get(uri)).body) as Map<String, dynamic>;
      }

      if (body['status'] == 'OK') {
        final loc     = body['result']['geometry']['location'];
        final lat     = (loc['lat'] as num).toDouble();
        final lng     = (loc['lng'] as num).toDouble();
        final address = body['result']['formatted_address'] as String;
        widget.onSelected(_AddressResult(formattedAddress: address, lat: lat, lng: lng));
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() { _errorText = AppLocalizations.of(context).regBizLocationError; _isLoading = false; });
      }
    } catch (_) {
      setState(() { _errorText = AppLocalizations.of(context).regBizSearchError; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20, left: 16, right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize:      MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(AppLocalizations.of(context).regBizSearchAddressTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus:  true,
            onChanged:  _onChanged,
            decoration: InputDecoration(
              hintText:   AppLocalizations.of(context).regBizSearchAddressHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _controller.clear();
                            setState(() { _predictions = []; _errorText = null; });
                          },
                        )
                      : null,
              filled:      true,
              fillColor:   Colors.white,
              border:        OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_errorText!,
                  style: const TextStyle(fontSize: 12, color: Colors.red)),
            ),
          if (_predictions.isNotEmpty)
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35),
              child: ListView.separated(
                shrinkWrap:      true,
                padding:         const EdgeInsets.only(top: 8),
                itemCount:       _predictions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final pred = _predictions[i];
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined,
                        color: AppColors.primary, size: 20),
                    title: Text(pred.description,
                        style: const TextStyle(fontSize: 13)),
                    onTap: () => _selectPrediction(pred),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4),
                    dense: true,
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
