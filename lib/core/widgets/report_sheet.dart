import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../data/repositories/reports_repository.dart';

/// Abre una hoja inferior para reportar contenido (promoción o establecimiento).
/// [contentType] debe ser 'promotion' o 'establishment'.
Future<void> showReportSheet(
  BuildContext context, {
  required String contentType,
  required String contentId,
  String? title,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ReportSheet(
      contentType: contentType,
      contentId:   contentId,
      title:       title,
    ),
  );
}

class _ReportSheet extends StatefulWidget {
  final String  contentType;
  final String  contentId;
  final String? title;

  const _ReportSheet({
    required this.contentType,
    required this.contentId,
    this.title,
  });

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  static const _reasons = <String>[
    'Contenido inapropiado u ofensivo',
    'Información falsa o engañosa',
    'Promoción vencida o no válida',
    'Spam o contenido duplicado',
    'Otro',
  ];

  String? _selected;
  final _noteCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selected == null) return;
    setState(() => _sending = true);
    try {
      await ReportsRepository().submitReport(
        contentType: widget.contentType,
        contentId:   widget.contentId,
        reason:      _selected!,
        note:        _noteCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:  Text('Gracias. Recibimos tu reporte y lo revisaremos.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  const Text('No se pudo enviar el reporte. Intenta de nuevo.'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color:        Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.flag_outlined, size: 20, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Reportar',
                    style: TextStyle(
                      fontSize:   17,
                      fontWeight: FontWeight.bold,
                      color:      AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '¿Por qué quieres reportar este contenido?',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              ..._reasons.map((r) => RadioListTile<String>(
                    value:    r,
                    groupValue: _selected,
                    onChanged: _sending ? null : (v) => setState(() => _selected = v),
                    title:    Text(r, style: const TextStyle(fontSize: 14)),
                    contentPadding: EdgeInsets.zero,
                    dense:    true,
                    activeColor: AppColors.primary,
                  )),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                enabled:    !_sending,
                maxLines:   2,
                maxLength:  300,
                decoration: InputDecoration(
                  hintText:  'Detalles (opcional)',
                  border:    OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selected == null || _sending) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Enviar reporte',
                          style: TextStyle(
                            fontSize:   15,
                            fontWeight: FontWeight.w600,
                            color:      Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
