import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:promofy/l10n/app_localizations.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/promotion_model.dart';
import '../../../data/repositories/business_repository.dart';
import '../../../data/repositories/categories_repository.dart';
import '../cubit/business_cubit.dart';

// ─── Pantalla de creación / edición de promoción ──────────────────────────────

class PromoFormScreen extends StatefulWidget {
  /// null → nueva promoción; non-null → editar existente.
  final PromotionModel? existing;

  /// Nombre del establecimiento, solo para mostrarlo en el header.
  final String establishmentName;

  /// Modo staff: ID del establecimiento asignado al gerente.
  /// Cuando está presente, el formulario bypasea BusinessCubit y usa
  /// BusinessRepository directamente.
  final String? establishmentId;

  /// ID del usuario staff (para subir fotos al Storage).
  final String? staffUserId;

  const PromoFormScreen({
    super.key,
    this.existing,
    required this.establishmentName,
    this.establishmentId,
    this.staffUserId,
  });

  bool get isEditing   => existing != null;
  bool get isStaffMode => establishmentId != null;

  @override
  State<PromoFormScreen> createState() => _PromoFormScreenState();
}

class _PromoFormScreenState extends State<PromoFormScreen> {
  // ── Formulario ────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;

  // Tipo de promo
  String _type = 'normal'; // 'normal' | 'flash' | 'birthday'

  // Promo normal
  Set<int>   _activeDays = {1, 2, 3, 4, 5}; // Lun–Vie por defecto
  TimeOfDay  _startTime  = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay  _endTime    = const TimeOfDay(hour: 22, minute: 0);

  // Promo flash
  DateTime? _flashStart;
  DateTime? _flashEnd;

  // Campos exclusivos de promo de cumpleaños
  late final TextEditingController _birthdayGiftCtrl;
  late final TextEditingController _birthdayTermsCtrl;

  // Común
  Uint8List? _photoBytes; // bytes de la imagen recién seleccionada
  String     _photoExt  = 'jpg'; // extensión para el upload
  String?    _photoUrl;  // URL ya existente (edición)
  bool     _isAdultOnly = false;
  bool     _isSaving    = false;

  // Categoría de la promo
  List<CategoryModel> _categories         = [];
  int?                _selectedCategoryId;

  // ── Constantes de UI ──────────────────────────────────────────────────────
  static const _dayShort = {
    1: 'Lun', 2: 'Mar', 3: 'Mié',
    4: 'Jue', 5: 'Vie', 6: 'Sáb', 7: 'Dom',
  };

  static const _months = [
    '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final p    = widget.existing;
    _nameCtrl  = TextEditingController(text: p?.name ?? '');
    _descCtrl  = TextEditingController(text: p?.description ?? '');
    _birthdayGiftCtrl  = TextEditingController(text: p?.birthdayGift  ?? '');
    _birthdayTermsCtrl = TextEditingController(text: p?.birthdayTerms ?? '');

    if (p != null) {
      _type               = p.type;
      _activeDays         = Set<int>.from(p.activeDays);
      _startTime          = _parseTime(p.startTime);
      _endTime            = _parseTime(p.endTime);
      _flashStart         = p.flashStartsAt?.toLocal();
      _flashEnd           = p.flashEndsAt?.toLocal();
      _photoUrl           = p.photoUrl;
      _isAdultOnly        = p.isAdultOnly;
      _selectedCategoryId = p.categoryId;
    }

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await CategoriesRepository().getCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _birthdayGiftCtrl.dispose();
    _birthdayTermsCtrl.dispose();
    super.dispose();
  }

  // ── Utilidades de tiempo ──────────────────────────────────────────────────

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(
        hour:   int.parse(parts[0]),
        minute: int.parse(parts[1]));
  }

  String _toDbTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}:00';

  String _displayTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';

  String _displayDateTime(DateTime dt) =>
      '${dt.day} ${_months[dt.month]} ${dt.year}  '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  // ── Acciones ──────────────────────────────────────────────────────────────

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 75);
    if (picked == null || !mounted) return;

    // Leer los bytes directamente del XFile (evita dart:io y problemas
    // de _Namespace en distintas versiones de Android/iOS)
    final bytes = await picked.readAsBytes();
    final ext   = picked.path.split('.').last.toLowerCase();

    setState(() {
      _photoBytes = bytes;
      _photoExt   = (ext == 'png') ? 'png' : 'jpg';
      _photoUrl   = null; // se sobreescribirá al guardar
    });
  }

  // ── Utilidades flash ──────────────────────────────────────────────────────

  /// True si a y b caen en el mismo día del calendario.
  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _pickFlashDateTime({required bool isStart}) async {
    final initial = isStart ? _flashStart : _flashEnd;
    final now     = DateTime.now();

    // ── Fin del evento: si ya hay inicio elegido, solo pedimos la HORA
    //    y forzamos el mismo día (la promo flash no puede cruzar medianoche).
    if (!isStart && _flashStart != null) {
      final time = await showTimePicker(
        context:     context,
        initialTime: initial != null
            ? TimeOfDay.fromDateTime(initial)
            : const TimeOfDay(hour: 21, minute: 0),
        helpText: AppLocalizations.of(context).promoFormEndTimeSameDay,
      );
      if (time == null || !mounted) return;
      setState(() {
        _flashEnd = DateTime(
          _flashStart!.year, _flashStart!.month, _flashStart!.day,
          time.hour, time.minute,
        );
      });
      return;
    }

    // ── Inicio (o fin sin inicio elegido): fecha + hora
    final date = await showDatePicker(
      context:     context,
      initialDate: initial ?? now,
      firstDate:   now,
      lastDate:    now.add(const Duration(days: 365)),
      helpText:    isStart
          ? AppLocalizations.of(context).promoFormStartDate
          : AppLocalizations.of(context).promoFormEndDate,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context:     context,
      initialTime: initial != null
          ? TimeOfDay.fromDateTime(initial)
          : TimeOfDay(hour: isStart ? 18 : 21, minute: 0),
      helpText: isStart
          ? AppLocalizations.of(context).promoFormStartTime
          : AppLocalizations.of(context).promoFormEndTime,
    );
    if (time == null || !mounted) return;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _flashStart = dt;
        // Si el fin ya estaba elegido en otro día, limpiarlo para forzar
        // que el usuario seleccione la hora de fin de nuevo.
        if (_flashEnd != null && !_sameDay(_flashEnd!, dt)) {
          _flashEnd = null;
        }
      } else {
        _flashEnd = dt;
      }
    });
  }

  void _showCategorySheet() {
    // IDs que tienen al menos un hijo → mostrar chevron derecho
    final parentIds = _categories
        .where((c) => c.parentId != null)
        .map((c) => int.tryParse(c.parentId!))
        .whereType<int>()
        .toSet();
    final l1List = _categories.where((c) => c.parentId == null).toList();

    int? sheetL1;
    int? sheetL2;

    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          final l2List = sheetL1 == null
              ? <CategoryModel>[]
              : _categories
                  .where((c) => c.parentId == sheetL1.toString())
                  .toList();
          final l3List = sheetL2 == null
              ? <CategoryModel>[]
              : _categories
                  .where((c) => c.parentId == sheetL2.toString())
                  .toList();

          // ── Ayudante: lista de tiles para un nivel ──────────────────
          List<Widget> buildItems(
            List<CategoryModel> cats,
            int? highlightId,
            void Function(int) onTap,
          ) =>
              cats.map((cat) {
                final id         = int.tryParse(cat.id);
                final isSelected = id != null && highlightId == id;
                final hasChild   = id != null && parentIds.contains(id);
                return ListTile(
                  dense: true,
                  title: Text(
                    cat.name,
                    style: TextStyle(
                      color:      isSelected ? AppColors.primary : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.w600   : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                            color: AppColors.primary, size: 20)
                      : hasChild
                          ? Icon(Icons.chevron_right,
                                color: Colors.grey.shade400, size: 20)
                          : null,
                  onTap: id != null ? () => onTap(id) : null,
                );
              }).toList();

          // ── Ayudante: encabezado de sección ─────────────────────────
          Widget secHeader(String label,
              {String? tag, VoidCallback? onStayHere}) =>
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 2),
                child: Row(children: [
                  Text(label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.primary, letterSpacing: 0.6,
                      )),
                  if (tag != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color:        Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(tag,
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade500)),
                    ),
                  ],
                  if (onStayHere != null) ...[
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding:       const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        minimumSize:   Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: onStayHere,
                      child: Text(AppLocalizations.of(context).promoFormSelectThis,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.primary)),
                    ),
                  ],
                ]),
              );

          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color:        Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Título
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                  child: Row(children: [
                    Text(AppLocalizations.of(context).promoFormCategorySheetTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:   17,
                          color:      AppColors.textDark,
                        )),
                    const Spacer(),
                    if (_selectedCategoryId != null)
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() => _selectedCategoryId = null);
                        },
                        child: Text(AppLocalizations.of(context).promoFormClear,
                            style: const TextStyle(color: AppColors.primary)),
                      ),
                  ]),
                ),
                Divider(color: Colors.grey.shade200, height: 1),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.62,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── L1: Categoría ─────────────────────────────
                        secHeader(AppLocalizations.of(context).promoFormCategoryLevel1),
                        ...buildItems(l1List, sheetL1, (id) {
                          if (!parentIds.contains(id)) {
                            Navigator.pop(ctx);
                            setState(() => _selectedCategoryId = id);
                          } else {
                            setSt(() { sheetL1 = id; sheetL2 = null; });
                          }
                        }),

                        // ── L2: Subcategoría ──────────────────────────
                        if (l2List.isNotEmpty) ...[
                          Divider(color: Colors.grey.shade100, height: 1),
                          secHeader(AppLocalizations.of(context).promoFormSubcategory,
                              tag: AppLocalizations.of(context).promoFormOptionalTag,
                              onStayHere: () {
                                Navigator.pop(ctx);
                                setState(() => _selectedCategoryId = sheetL1);
                              }),
                          ...buildItems(l2List, sheetL2, (id) {
                            if (!parentIds.contains(id)) {
                              Navigator.pop(ctx);
                              setState(() => _selectedCategoryId = id);
                            } else {
                              setSt(() => sheetL2 = id);
                            }
                          }),
                        ],

                        // ── L3: Especialidad ──────────────────────────
                        if (l3List.isNotEmpty) ...[
                          Divider(color: Colors.grey.shade100, height: 1),
                          secHeader(AppLocalizations.of(context).promoFormSpecialty,
                              tag: AppLocalizations.of(context).promoFormOptionalTag,
                              onStayHere: () {
                                Navigator.pop(ctx);
                                setState(() => _selectedCategoryId = sheetL2);
                              }),
                          ...buildItems(l3List, _selectedCategoryId, (id) {
                            Navigator.pop(ctx);
                            setState(() => _selectedCategoryId = id);
                          }),
                        ],

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _validate() {
    final l10n = AppLocalizations.of(context);
    if (_nameCtrl.text.trim().isEmpty) return l10n.promoFormErrorNameRequired;

    if (_type == 'normal') {
      if (_activeDays.isEmpty) return l10n.promoFormErrorSelectDay;
    } else if (_type == 'flash') {
      if (_flashStart == null) return l10n.promoFormErrorStartDateTime;
      if (_flashEnd   == null) return l10n.promoFormErrorEndTime;
      if (!_flashEnd!.isAfter(_flashStart!)) {
        return l10n.promoFormErrorEndAfterStart;
      }
      if (!_sameDay(_flashStart!, _flashEnd!)) {
        return l10n.promoFormErrorSameDay;
      }
    }
    // birthday: no requiere validación de horario (siempre todos los días)
    return null;
  }

  /// Dialog de confirmación solo para promociones NUEVAS.
  /// Devuelve true si el usuario confirma, false si cancela.
  Future<bool> _confirmCreate() async {
    final name = _nameCtrl.text.trim();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color:  Colors.orange.shade50,
                shape:  BoxShape.circle,
              ),
              child: Icon(Icons.lock_clock_outlined,
                  size: 28, color: Colors.orange.shade700),
            ),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context).promoFormConfirmTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            if (name.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color:        AppColors.primary.withAlpha(12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  AppLocalizations.of(context).promoFormConfirmName(name),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize:   14,
                    fontWeight: FontWeight.w600,
                    color:      AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade700, height: 1.5),
                children: [
                  TextSpan(text: AppLocalizations.of(context).promoFormConfirmIntro),
                  TextSpan(
                    text: AppLocalizations.of(context).promoFormConfirmLockWarning,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  TextSpan(
                    text: AppLocalizations.of(context).promoFormConfirmReview,
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLocalizations.of(context).promoFormReviewMore),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize:     const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              AppLocalizations.of(context).promoFormConfirmCreate,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:  Text(error),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    // Confirmación obligatoria solo para promociones nuevas
    if (!widget.isEditing) {
      final ok = await _confirmCreate();
      if (!ok) return;
    }

    setState(() => _isSaving = true);

    try {
      // ── Campos comunes de schedule ──────────────────────────────────────
      final List<int> activeDays;
      final String    startTime;
      final String    endTime;
      DateTime?       flashStart;
      DateTime?       flashEnd;

      if (_type == 'flash') {
        activeDays = [_flashStart!.weekday];
        startTime  = '${_flashStart!.hour.toString().padLeft(2, '0')}:'
                     '${_flashStart!.minute.toString().padLeft(2, '0')}:00';
        endTime    = '${_flashEnd!.hour.toString().padLeft(2, '0')}:'
                     '${_flashEnd!.minute.toString().padLeft(2, '0')}:00';
        flashStart = _flashStart;
        flashEnd   = _flashEnd;
      } else if (_type == 'birthday') {
        // Disponible todos los días, sin restricción de horario
        activeDays = [1, 2, 3, 4, 5, 6, 7];
        startTime  = '00:00:00';
        endTime    = '23:59:00';
      } else {
        activeDays = _activeDays.toList()..sort();
        startTime  = _toDbTime(_startTime);
        endTime    = _toDbTime(_endTime);
      }

      final birthdayGift  = _type == 'birthday' && _birthdayGiftCtrl.text.trim().isNotEmpty
          ? _birthdayGiftCtrl.text.trim() : null;
      final birthdayTerms = _type == 'birthday' && _birthdayTermsCtrl.text.trim().isNotEmpty
          ? _birthdayTermsCtrl.text.trim() : null;

      if (widget.isStaffMode) {
        // ── Modo gerente: usa BusinessRepository directamente ─────────────
        final repo   = BusinessRepository();
        final uid    = widget.staffUserId ?? '';
        String? photoUrl = _photoUrl;
        if (_photoBytes != null && uid.isNotEmpty) {
          photoUrl = await repo.uploadPromoPhoto(
            userId:    uid,
            bytes:     _photoBytes!,
            extension: _photoExt,
          );
        }
        if (widget.isEditing) {
          await repo.updatePromotion(
            id:            widget.existing!.id,
            name:          _nameCtrl.text.trim(),
            description:   _descCtrl.text.trim(),
            type:          _type,
            activeDays:    activeDays,
            startTime:     startTime,
            endTime:       endTime,
            flashStartsAt: flashStart,
            flashEndsAt:   flashEnd,
            photoUrl:      photoUrl,
            isAdultOnly:   _isAdultOnly,
            categoryId:    _selectedCategoryId,
            birthdayGift:  birthdayGift,
            birthdayTerms: birthdayTerms,
          );
        } else {
          await repo.createPromotion(
            establishmentId: widget.establishmentId!,
            name:            _nameCtrl.text.trim(),
            description:     _descCtrl.text.trim(),
            type:            _type,
            activeDays:      activeDays,
            startTime:       startTime,
            endTime:         endTime,
            flashStartsAt:   flashStart,
            flashEndsAt:     flashEnd,
            photoUrl:        photoUrl,
            isAdultOnly:     _isAdultOnly,
            categoryId:      _selectedCategoryId,
            birthdayGift:    birthdayGift,
            birthdayTerms:   birthdayTerms,
          );
        }
      } else {
        // ── Modo dueño: usa BusinessCubit ─────────────────────────────────
        final cubit = context.read<BusinessCubit>();
        String? photoUrl = _photoUrl;
        if (_photoBytes != null) {
          photoUrl = await cubit.uploadPromoPhoto(_photoBytes!, _photoExt);
        }
        if (widget.isEditing) {
          await cubit.updatePromo(
            promoId:       widget.existing!.id,
            name:          _nameCtrl.text.trim(),
            description:   _descCtrl.text.trim(),
            type:          _type,
            activeDays:    activeDays,
            startTime:     startTime,
            endTime:       endTime,
            flashStartsAt: flashStart,
            flashEndsAt:   flashEnd,
            photoUrl:      photoUrl,
            isAdultOnly:   _isAdultOnly,
            categoryId:    _selectedCategoryId,
            birthdayGift:  birthdayGift,
            birthdayTerms: birthdayTerms,
          );
        } else {
          await cubit.createPromo(
            name:          _nameCtrl.text.trim(),
            description:   _descCtrl.text.trim(),
            type:          _type,
            activeDays:    activeDays,
            startTime:     startTime,
            endTime:       endTime,
            flashStartsAt: flashStart,
            flashEndsAt:   flashEnd,
            photoUrl:      photoUrl,
            isAdultOnly:   _isAdultOnly,
            categoryId:    _selectedCategoryId,
            birthdayGift:  birthdayGift,
            birthdayTerms: birthdayTerms,
          );
        }
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:         Text(AppLocalizations.of(context).promoFormSaveError(e.toString())),
          backgroundColor: Colors.red.shade700,
          behavior:        SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title:   Text(AppLocalizations.of(context).promoFormDeleteTitle),
        content: Text(
            AppLocalizations.of(context).promoFormDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:     Text(AppLocalizations.of(context).promoFormCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:     TextButton.styleFrom(foregroundColor: Colors.red),
            child:     Text(AppLocalizations.of(context).promoFormDelete),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      if (widget.isStaffMode) {
        await BusinessRepository().deletePromotion(widget.existing!.id);
      } else {
        await context.read<BusinessCubit>().deletePromo(widget.existing!.id);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:         Text(AppLocalizations.of(context).promoFormDeleteError(e.toString())),
          backgroundColor: Colors.red.shade700,
          behavior:        SnackBarBehavior.floating,
        ));
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.isEditing
              ? AppLocalizations.of(context).promoFormEditTitle
              : AppLocalizations.of(context).promoFormNewTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.isEditing)
            IconButton(
              onPressed: _isSaving ? null : _delete,
              icon:  const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: AppLocalizations.of(context).promoFormDelete,
            ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Negocio al que pertenece
                    _SectionHeader(
                      icon:  Icons.storefront_outlined,
                      label: widget.establishmentName,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),

                    // ── Tipo ────────────────────────────────────────────────
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label(AppLocalizations.of(context).promoFormTypeLabel),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              _TypeChip(
                                label:    AppLocalizations.of(context).promoFormTypeNormal,
                                icon:     Icons.event_repeat_outlined,
                                selected: _type == 'normal',
                                onTap:    () => setState(() => _type = 'normal'),
                              ),
                              _TypeChip(
                                label:    AppLocalizations.of(context).promoFormTypeFlash,
                                icon:     Icons.bolt_outlined,
                                selected: _type == 'flash',
                                onTap:    () => setState(() => _type = 'flash'),
                              ),
                              _TypeChip(
                                label:    AppLocalizations.of(context).promoFormTypeBirthday,
                                icon:     Icons.cake_outlined,
                                selected: _type == 'birthday',
                                onTap:    () => setState(() => _type = 'birthday'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _type == 'normal'
                                ? AppLocalizations.of(context).promoFormTypeNormalDesc
                                : _type == 'flash'
                                    ? AppLocalizations.of(context).promoFormTypeFlashDesc
                                    : AppLocalizations.of(context).promoFormTypeBirthdayDesc,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Nombre y descripción ─────────────────────────────────
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label(AppLocalizations.of(context).promoFormNameLabel),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller:  _nameCtrl,
                            decoration:  _inputDeco(AppLocalizations.of(context).promoFormNameHint),
                            maxLength:   80,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const SizedBox(height: 12),
                          _Label(AppLocalizations.of(context).promoFormDescriptionLabel),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _descCtrl,
                            decoration: _inputDeco(
                                AppLocalizations.of(context).promoFormDescriptionHint),
                            maxLength:  300,
                            maxLines:   3,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Horario (oculto para cumpleaños) ────────────────────
                    if (_type != 'birthday') ...[
                      _Card(
                        child: _type == 'normal'
                            ? _NormalSchedule(
                                activeDays: _activeDays,
                                startTime:  _startTime,
                                endTime:    _endTime,
                                dayShort:   _dayShort,
                                displayTime: _displayTime,
                                onDayToggled: (d, v) {
                                  setState(() {
                                    if (v) { _activeDays.add(d); }
                                    else   { _activeDays.remove(d); }
                                  });
                                },
                                onPickStart: () async {
                                  final t = await showTimePicker(
                                      context: context,
                                      initialTime: _startTime);
                                  if (t != null) setState(() => _startTime = t);
                                },
                                onPickEnd: () async {
                                  final t = await showTimePicker(
                                      context: context,
                                      initialTime: _endTime);
                                  if (t != null) setState(() => _endTime = t);
                                },
                              )
                            : _FlashSchedule(
                                flashStart:      _flashStart,
                                flashEnd:        _flashEnd,
                                startSelected:   _flashStart != null,
                                displayDateTime: _displayDateTime,
                                onPickStart: () =>
                                    _pickFlashDateTime(isStart: true),
                                onPickEnd: () =>
                                    _pickFlashDateTime(isStart: false),
                              ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Campos de cumpleaños ─────────────────────────────────
                    if (_type == 'birthday') ...[
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label(AppLocalizations.of(context).promoFormBirthdayGiftLabel),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _birthdayGiftCtrl,
                              decoration: _inputDeco(
                                  AppLocalizations.of(context).promoFormBirthdayGiftHint),
                              maxLength: 200,
                              maxLines:  2,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                            const SizedBox(height: 12),
                            _Label(AppLocalizations.of(context).promoFormBirthdayTermsLabel),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _birthdayTermsCtrl,
                              decoration: _inputDeco(
                                  AppLocalizations.of(context).promoFormBirthdayTermsHint),
                              maxLength: 300,
                              maxLines:  2,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Foto ────────────────────────────────────────────────
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label(AppLocalizations.of(context).promoFormPhotoLabel),
                          const SizedBox(height: 10),
                          _PhotoPicker(
                            photoBytes: _photoBytes,
                            photoUrl:   _photoUrl,
                            onTap:      _pickPhoto,
                            onRemove: (_photoBytes != null || _photoUrl != null)
                                ? () => setState(() {
                                      _photoBytes = null;
                                      _photoUrl   = null;
                                    })
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Categoría ────────────────────────────────────────────
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label(AppLocalizations.of(context).promoFormCategoryLabel),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _categories.isEmpty ? null : _showCategorySheet,
                            child: Container(
                              width:   double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color:        Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selectedCategoryId != null
                                      ? AppColors.primary.withAlpha(160)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.category_outlined,
                                    size:  18,
                                    color: _selectedCategoryId != null
                                        ? AppColors.primary
                                        : Colors.grey.shade400,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _selectedCategoryId != null
                                          ? (_categories
                                                  .where((c) =>
                                                      int.tryParse(c.id) ==
                                                      _selectedCategoryId)
                                                  .firstOrNull
                                                  ?.name ??
                                              AppLocalizations.of(context).promoFormCategorySelected)
                                          : _categories.isEmpty
                                              ? AppLocalizations.of(context).promoFormCategoryLoading
                                              : AppLocalizations.of(context).promoFormCategoryNone,
                                      style: TextStyle(
                                        fontSize:   14,
                                        color: _selectedCategoryId != null
                                            ? AppColors.textDark
                                            : Colors.grey.shade400,
                                        fontWeight: _selectedCategoryId != null
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      size:  18,
                                      color: Colors.grey.shade400),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Contenido adulto ────────────────────────────────────
                    _Card(
                      child: Row(
                        children: [
                          Icon(Icons.no_adult_content,
                              size: 20,
                              color: Colors.orange.shade600),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context).promoFormAdultTitle,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                                Text(
                                  AppLocalizations.of(context).promoFormAdultSubtitle,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value:       _isAdultOnly,
                            onChanged:   (v) => setState(() => _isAdultOnly = v),
                            activeColor: Colors.orange.shade600,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

      // ── Botón guardar fijo ────────────────────────────────────────────────
      bottomNavigationBar: _isSaving
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    minimumSize:  const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    widget.isEditing
                        ? AppLocalizations.of(context).promoFormSaveChanges
                        : AppLocalizations.of(context).promoFormCreate,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
    );
  }
}

// ─── Sub-widgets: horario normal ──────────────────────────────────────────────

class _NormalSchedule extends StatelessWidget {
  final Set<int>        activeDays;
  final TimeOfDay       startTime;
  final TimeOfDay       endTime;
  final Map<int,String> dayShort;
  final String Function(TimeOfDay) displayTime;
  final void Function(int, bool)   onDayToggled;
  final VoidCallback               onPickStart;
  final VoidCallback               onPickEnd;

  const _NormalSchedule({
    required this.activeDays,
    required this.startTime,
    required this.endTime,
    required this.dayShort,
    required this.displayTime,
    required this.onDayToggled,
    required this.onPickStart,
    required this.onPickEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(AppLocalizations.of(context).promoFormActiveDaysLabel),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (int d = 1; d <= 7; d++)
              _DayChip(
                label:    dayShort[d]!,
                selected: activeDays.contains(d),
                onTap:    () => onDayToggled(d, !activeDays.contains(d)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _Label(AppLocalizations.of(context).promoFormScheduleLabel),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _TimePicker(
                label: AppLocalizations.of(context).promoFormStartLabel,
                time:  displayTime(startTime),
                onTap: onPickStart,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('–',
                  style: TextStyle(color: Colors.grey, fontSize: 18)),
            ),
            Expanded(
              child: _TimePicker(
                label: AppLocalizations.of(context).promoFormEndLabel,
                time:  displayTime(endTime),
                onTap: onPickEnd,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Sub-widgets: horario flash ───────────────────────────────────────────────

class _FlashSchedule extends StatelessWidget {
  final DateTime?  flashStart;
  final DateTime?  flashEnd;
  /// true cuando ya se eligió el inicio → el fin solo pide hora (mismo día).
  final bool       startSelected;
  final String Function(DateTime) displayDateTime;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  const _FlashSchedule({
    required this.flashStart,
    required this.flashEnd,
    required this.displayDateTime,
    required this.onPickStart,
    required this.onPickEnd,
    this.startSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(AppLocalizations.of(context).promoFormEventStartLabel),
        const SizedBox(height: 8),
        _DateTimePicker(
          value:  flashStart != null ? displayDateTime(flashStart!) : null,
          hint:   AppLocalizations.of(context).promoFormPickDateTime,
          onTap:  onPickStart,
        ),
        const SizedBox(height: 14),
        _Label(startSelected
            ? AppLocalizations.of(context).promoFormEndTimeSameDayLabel
            : AppLocalizations.of(context).promoFormEventEndLabel),
        const SizedBox(height: 8),
        _DateTimePicker(
          value:  flashEnd != null ? displayDateTime(flashEnd!) : null,
          hint:   startSelected
              ? AppLocalizations.of(context).promoFormPickEndTime
              : AppLocalizations.of(context).promoFormPickDateTime,
          onTap:  onPickEnd,
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 13, color: Colors.amber.shade700),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                AppLocalizations.of(context).promoFormFlashInfo,
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade500, height: 1.4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Sub-widgets reutilizables ─────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withAlpha(13),
              blurRadius: 8,
              offset:     const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  const _SectionHeader({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final bool         selected;
  final VoidCallback onTap;
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color:        selected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
          border:       Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16,
                color: selected ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String       label;
  final bool         selected;
  final VoidCallback onTap;
  const _DayChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width:  42,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:        selected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.grey.shade600),
        ),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String       label;
  final String       time;
  final VoidCallback onTap;
  const _TimePicker({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:        Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.access_time_outlined,
                  size: 15, color: AppColors.primary),
              const SizedBox(width: 5),
              Text(time,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  final String?      value;
  final String       hint;
  final VoidCallback onTap;
  const _DateTimePicker({required this.value, required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:   double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:        Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(
            color: value != null
                ? AppColors.primary.withAlpha(120)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size:  16,
                color: value != null ? AppColors.primary : Colors.grey.shade400),
            const SizedBox(width: 10),
            Text(
              value ?? hint,
              style: TextStyle(
                  fontSize:   14,
                  color:      value != null ? AppColors.textDark : Colors.grey.shade400,
                  fontWeight: value != null ? FontWeight.w600 : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final Uint8List?   photoBytes; // imagen nueva (ya leída como bytes)
  final String?      photoUrl;   // URL existente (edición)
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _PhotoPicker({
    required this.photoBytes,
    required this.photoUrl,
    required this.onTap,
    this.onRemove,
  });

  bool get hasPhoto => photoBytes != null || photoUrl != null;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 150,
              width:  double.infinity,
              decoration: BoxDecoration(
                color:        Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: Colors.grey.shade300),
              ),
              child: hasPhoto
                  ? (photoBytes != null
                      // Imagen local recién seleccionada
                      ? Image.memory(photoBytes!, fit: BoxFit.cover,
                          width: double.infinity, height: 150)
                      // Imagen ya guardada en Storage
                      : Image.network(photoUrl!, fit: BoxFit.cover,
                          width: double.infinity, height: 150))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 36, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(AppLocalizations.of(context).promoFormPhotoTapToAdd,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade500)),
                      ],
                    ),
            ),
          ),
        ),
        if (hasPhoto && onRemove != null)
          Positioned(
            top: 6, right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color:  Colors.black54,
                  shape:  BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Helpers de formulario ────────────────────────────────────────────────────

InputDecoration _inputDeco(String hint) => InputDecoration(
  hintText:        hint,
  filled:          true,
  fillColor:       Colors.grey.shade50,
  contentPadding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border:          OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide:   BorderSide(color: Colors.grey.shade300),
  ),
  enabledBorder:   OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide:   BorderSide(color: Colors.grey.shade300),
  ),
  focusedBorder:   OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide:   const BorderSide(color: AppColors.primary),
  ),
  counterStyle: const TextStyle(fontSize: 11),
);
