import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:promofy/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/business/cubit/stats_cubit.dart';
import '../cubit/loyalty_cubit.dart';
import '../cubit/loyalty_state.dart';

/// El dueño escanea el QR del cliente para registrar la visita.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _processing = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final barcode = capture.barcodes.firstOrNull;
    final raw     = barcode?.rawValue;
    if (raw == null || raw.isEmpty) return;

    // El QR del cliente contiene solo su userId (UUID)
    final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false);

    if (!uuidRegex.hasMatch(raw)) {
      _showInvalidQrSnack();
      return;
    }

    setState(() => _processing = true);
    await _ctrl.stop();
    if (!mounted) return;

    // Si el programa exige consumo mínimo, pedir el monto ANTES de sellar.
    final st      = context.read<LoyaltyCubit>().state;
    final program = st is LoyaltyLoaded ? st.program : null;
    double? ticketAmount;
    if (program != null && program.minTicketMxn > 0) {
      ticketAmount = await _askTicketAmount(program.minTicketMxn);
      if (!mounted) return;
      if (ticketAmount == null) {
        // Canceló → reanudar escáner.
        setState(() => _processing = false);
        await _ctrl.start();
        return;
      }
    }

    await context.read<LoyaltyCubit>().recordVisit(
          clientId:     raw,
          ticketAmount: ticketAmount,
        );
    if (!mounted) return;

    // Mostramos el bottom-sheet de resultado. Si ya capturamos el monto
    // (consumo mínimo), no lo volvemos a pedir.
    final result = context.read<LoyaltyCubit>().state;
    if (result is LoyaltyScanResult) {
      await _showResult(result, askTicket: ticketAmount == null);
    }

    if (!mounted) return;
    context.read<LoyaltyCubit>().dismissScanResult();
    Navigator.of(context).pop();
  }

  /// Diálogo para capturar el monto del ticket (regla de consumo mínimo).
  /// Devuelve el monto (>= [min]) o null si se cancela.
  Future<double?> _askTicketAmount(double min) async {
    final ctrl = TextEditingController();
    final l10n = AppLocalizations.of(context);
    return showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        String? error;
        return StatefulBuilder(
          builder: (ctx, setLocal) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(l10n.qrTicketAmountTitle,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.qrMinTicketHint(min.toStringAsFixed(min == min.roundToDouble() ? 0 : 2)),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 12),
                TextField(
                  controller:   ctrl,
                  autofocus:    true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    hintText:   '0.00',
                    errorText:  error,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.qrTicketCancel),
              ),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(ctrl.text.trim());
                  if (amount == null || amount < min) {
                    setLocal(() => error = l10n.qrMinTicketError(
                        min.toStringAsFixed(min == min.roundToDouble() ? 0 : 2)));
                    return;
                  }
                  Navigator.of(ctx).pop(amount);
                },
                child: Text(l10n.qrTicketConfirm),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInvalidQrSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:  Text(AppLocalizations.of(context).qrInvalidCode),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showResult(LoyaltyScanResult r, {bool askTicket = true}) async {
    // Capturamos el context antes del await para poder leer StatsCubit
    // desde dentro del builder del modal (que vive en una ruta separada).
    final statsCubit = context.read<StatsCubit>();

    await showModalBottomSheet<void>(
      context:       context,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ScanResultSheet(
        result: r,
        onTicketSaved: (askTicket && r.ok && r.visitId != null)
            ? (amount) => statsCubit.updateVisitTicket(
                  visitId: r.visitId!,
                  amount:  amount,
                )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(AppLocalizations.of(context).qrScanTitle),
        actions: [
          IconButton(
            icon:     const Icon(Icons.flash_on),
            onPressed: () => _ctrl.toggleTorch(),
            tooltip:  AppLocalizations.of(context).qrTorch,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Solo renderizamos la cámara mientras NO estamos procesando.
          // Al quitar el PlatformView del árbol, el teclado del campo de
          // "Importe de la cuenta" funciona en el bottom-sheet de resultado.
          if (!_processing)
            MobileScanner(
              controller: _ctrl,
              onDetect:   _onDetect,
            )
          else
            const ColoredBox(color: Colors.black, child: SizedBox.expand()),
          // Marco de escaneo
          Center(
            child: Container(
              width:  220,
              height: 220,
              decoration: BoxDecoration(
                border:       Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Instrucción
          Positioned(
            bottom: 60,
            left:   0,
            right:  0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color:        Colors.black.withAlpha(140),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  AppLocalizations.of(context).qrPointInstruction,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
          if (_processing)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }
}

// ─── Bottom-sheet de resultado ────────────────────────────────────────────────

class _ScanResultSheet extends StatelessWidget {
  final LoyaltyScanResult              result;
  final Future<void> Function(double)? onTicketSaved;

  const _ScanResultSheet({
    required this.result,
    this.onTicketSaved,
  });

  String _errorMessage(BuildContext context, String? error) {
    final l10n = AppLocalizations.of(context);
    switch (error) {
      case 'unauthorized':
        return l10n.qrErrorUnauthorized;
      case 'program_inactive':
        return l10n.qrErrorProgramInactive;
      case 'network_error':
        return l10n.qrErrorNetwork;
      case 'min_ticket':
        return l10n.qrErrorMinTicket;
      case 'already_today':
        return l10n.qrErrorAlreadyToday;
      case 'too_soon':
        return l10n.qrErrorTooSoon;
      case 'reward_expired':
        return l10n.qrErrorRewardExpired;
      default:
        return l10n.qrErrorUnexpected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!result.ok) {
      return _Sheet(
        icon:    Icons.error_outline,
        color:   Colors.red,
        title:   l10n.qrCouldNotRegister,
        message: _errorMessage(context, result.error),
      );
    }

    if (result.rewardReady) {
      return _Sheet(
        icon:         Icons.card_giftcard,
        color:        Colors.amber.shade700,
        title:        l10n.qrRewardWonTitle,
        message:      l10n.qrRewardWonMessage(result.visitsRequired ?? 0),
        totalVisits:  result.programVisits,
        required:     result.visitsRequired,
        onTicketSaved: onTicketSaved,
      );
    }

    final left = (result.visitsRequired ?? 0) - (result.programVisits ?? 0);
    return _Sheet(
      icon:    Icons.check_circle_outline,
      color:   Colors.green,
      title:   l10n.qrVisitRegistered,
      message: left > 0
          ? l10n.qrVisitsLeft(left)
          : l10n.qrProgramCompleted,
      totalVisits:  result.programVisits,
      required:     result.visitsRequired,
      onTicketSaved: onTicketSaved,
    );
  }
}

class _Sheet extends StatefulWidget {
  final IconData  icon;
  final Color     color;
  final String    title;
  final String    message;
  final int?      totalVisits;
  final int?      required;
  /// Si se proporciona, se muestra el campo de importe y se llama al cerrar.
  final Future<void> Function(double)? onTicketSaved;

  const _Sheet({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.totalVisits,
    this.required,
    this.onTicketSaved,
  });

  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> {
  final _ticketCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _ticketCtrl.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    final raw    = _ticketCtrl.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(raw);

    if (amount != null && amount > 0 && widget.onTicketSaved != null) {
      setState(() => _saving = true);
      await widget.onTicketSaved!(amount);
      if (mounted) setState(() => _saving = false);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final showTicketInput = widget.onTicketSaved != null;

    return Padding(
      // Sube el sheet cuando el teclado aparece
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color:        Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Icon(widget.icon, size: 56, color: widget.color),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize:   20,
                  fontWeight: FontWeight.bold,
                  color:      widget.color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color:    AppColors.textDark,
                  height:   1.4,
                ),
              ),
              if (widget.totalVisits != null && widget.required != null) ...[
                const SizedBox(height: 16),
                _ProgressBar(
                  current: widget.totalVisits!,
                  total:   widget.required!,
                ),
              ],

              // ── Campo de importe (solo en escaneos exitosos) ──────────────
              if (showTicketInput) ...[
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context).qrBillAmountLabel,
                    style: const TextStyle(
                      fontSize:   12,
                      fontWeight: FontWeight.w600,
                      color:      AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller:  _ticketCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[\d.,]'),
                    ),
                  ],
                  decoration: InputDecoration(
                    hintText:    AppLocalizations.of(context).qrBillAmountHint,
                    prefixText:  '\$ ',
                    filled:      true,
                    fillColor:   Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:   BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:   BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:   const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical:   12,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context).qrBillAmountHelper,
                  style: TextStyle(
                    fontSize: 11,
                    color:    Colors.grey.shade500,
                    height:   1.3,
                  ),
                ),
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _close,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width:  20,
                        height: 20,
                        child:  CircularProgressIndicator(
                          strokeWidth: 2,
                          color:       Colors.white,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context).qrDone,
                        style: const TextStyle(
                          fontSize:   15,
                          fontWeight: FontWeight.w600,
                          color:      Colors.white,
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

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct   = (current / total).clamp(0.0, 1.0);
    final color = pct >= 1.0 ? Colors.amber.shade700 : AppColors.primary;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context).qrVisitsCount(current, total),
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: color)),
            Text('${(pct * 100).round()}%',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value:           pct,
            minHeight:       8,
            backgroundColor: Colors.grey.shade200,
            valueColor:      AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
