import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/establishment_model.dart';
import '../../../data/repositories/loyalty_repository.dart';
import '../cubit/loyalty_cubit.dart';
import '../cubit/loyalty_state.dart';
import '../screens/loyalty_program_form_screen.dart';
import '../screens/qr_scanner_screen.dart';
import 'loyalty_clients_sheet.dart';

/// Sección "Programa de lealtad" que vive dentro de BusinessTabScreen.
/// Recibe el establecimiento actualmente seleccionado y crea su propio
/// LoyaltyCubit para mantenerlo aislado.
class LoyaltySection extends StatelessWidget {
  final EstablishmentModel establishment;
  const LoyaltySection({super.key, required this.establishment});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(establishment.id), // recrea el cubit al cambiar est.
      create: (_) => LoyaltyCubit(
        repository:        LoyaltyRepository(),
        establishmentId:   establishment.id,
        establishmentName: establishment.name,
        establishmentLogo: establishment.logoUrl,
      )..load(),
      child: const _LoyaltySectionBody(),
    );
  }
}

class _LoyaltySectionBody extends StatelessWidget {
  const _LoyaltySectionBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoyaltyCubit, LoyaltyState>(
      builder: (context, state) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Encabezado ───────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.loyalty, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Programa de lealtad',
                      style: TextStyle(
                          fontSize:   15,
                          fontWeight: FontWeight.bold,
                          color:      AppColors.textDark),
                    ),
                  ),
                  if (state is LoyaltyLoaded && state.program != null)
                    _ScanButton(context: context),
                ],
              ),
              const SizedBox(height: 12),

              // ── Contenido ────────────────────────────────────────
              if (state is LoyaltyLoading || state is LoyaltySaving)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                )
              else if (state is LoyaltyError)
                Text(state.message,
                    style: const TextStyle(color: Colors.red, fontSize: 13))
              else if (state is LoyaltyLoaded)
                _LoadedContent(state: state),
            ],
          ),
        );
      },
    );
  }
}

// ─── Botón "Escanear" ─────────────────────────────────────────────────────────

class _ScanButton extends StatelessWidget {
  final BuildContext context;
  const _ScanButton({required this.context});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<LoyaltyCubit>(),
            child: const QrScannerScreen(),
          ),
        ),
      ),
      icon:  const Icon(Icons.qr_code_scanner, size: 16),
      label: const Text('Escanear',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        padding:      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize:  Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

// ─── Contenido cargado ────────────────────────────────────────────────────────

class _LoadedContent extends StatelessWidget {
  final LoyaltyLoaded state;
  const _LoadedContent({required this.state});

  static final _fmt = DateFormat('dd/MM/yyyy', 'es_MX');

  @override
  Widget build(BuildContext context) {
    final program = state.program;

    // Sin programa → mostrar botón de creación
    if (program == null) {
      return _NoProgramView();
    }

    final isOngoing = program.isOngoing;
    final isExpired = program.isExpired;
    final daysLeft  = program.daysLeft;

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (!program.isActive) {
      statusColor = Colors.grey;
      statusLabel = 'Desactivado';
      statusIcon  = Icons.pause_circle_outline;
    } else if (isExpired) {
      statusColor = Colors.red.shade600;
      statusLabel = 'Venció el ${_fmt.format(program.endsAt)}';
      statusIcon  = Icons.timer_off_outlined;
    } else if (daysLeft <= 7) {
      statusColor = Colors.orange.shade700;
      statusLabel = 'Vence en $daysLeft día${daysLeft != 1 ? "s" : ""}';
      statusIcon  = Icons.timer_outlined;
    } else {
      statusColor = Colors.green.shade600;
      statusLabel = 'Activo — termina ${_fmt.format(program.endsAt)}';
      statusIcon  = Icons.check_circle_outline;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge de estado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color:        statusColor.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
            border:       Border.all(color: statusColor.withAlpha(60)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 13, color: statusColor),
              const SizedBox(width: 5),
              Text(statusLabel,
                  style: TextStyle(
                      fontSize:   12,
                      fontWeight: FontWeight.w500,
                      color:      statusColor)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Datos del programa
        _ProgramDataRow(
          icon:  Icons.confirmation_number_outlined,
          label: 'Visitas requeridas',
          value: '${program.visitsRequired}',
        ),
        _ProgramDataRow(
          icon:  Icons.card_giftcard_outlined,
          label: 'Premio',
          value: program.rewardDescription,
        ),
        _ProgramDataRow(
          icon:  Icons.date_range_outlined,
          label: 'Inicio',
          value: _fmt.format(program.startsAt),
        ),
        _ProgramDataRow(
          icon:  Icons.event_outlined,
          label: 'Fin',
          value: _fmt.format(program.endsAt),
        ),

        // Contador de participantes + botón "Ver clientes"
        // El botón aparece siempre que hay programa; las pills solo cuando hay tarjetas.
        const SizedBox(height: 8),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        const SizedBox(height: 10),
        Row(
          children: [
            if (state.cardsLoaded && state.cards.isNotEmpty)
              Expanded(
                child: _ClientStats(
                  cards:    state.cards,
                  required: program.visitsRequired,
                ),
              )
            else
              const Spacer(),
            _ViewClientsButton(
              programId:   program.id,
              programName: program.rewardDescription,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Acción: desactivar o crear nuevo
        if (isOngoing)
          OutlinedButton.icon(
            onPressed: () => _confirmDeactivate(context),
            icon:  const Icon(Icons.stop_circle_outlined, size: 16),
            label: const Text('Terminar programa ahora',
                style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              side:            BorderSide(color: Colors.red.shade300),
              minimumSize:     const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: () => _openForm(context),
            icon:  const Icon(Icons.add_circle_outline, size: 16),
            label: const Text('Crear nuevo programa',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
      ],
    );
  }

  void _openForm(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<LoyaltyCubit>(),
        child: const LoyaltyProgramFormScreen(),
      ),
    ));
  }

  void _confirmDeactivate(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title:   const Text('¿Terminar programa?'),
        content: const Text(
            'Todos los clientes dejarán de acumular visitas en este programa. '
            'Podrás crear uno nuevo cuando quieras.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:     const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<LoyaltyCubit>().deactivateProgram();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Terminar'),
          ),
        ],
      ),
    );
  }
}

// ─── Vista sin programa ───────────────────────────────────────────────────────

class _NoProgramView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fideliza a tus clientes con un sistema de sellos digital. '
          'Define cuántas visitas necesitan para ganar su premio.',
          style: TextStyle(
              fontSize: 13, color: Colors.grey.shade600, height: 1.4),
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<LoyaltyCubit>(),
              child: const LoyaltyProgramFormScreen(),
            ),
          )),
          icon:  const Icon(Icons.add_circle_outline, size: 16),
          label: const Text('Crear programa',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

// ─── Fila de dato ─────────────────────────────────────────────────────────────

class _ProgramDataRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  const _ProgramDataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }
}

// ─── Estadísticas de clientes ─────────────────────────────────────────────────

class _ClientStats extends StatelessWidget {
  final List<dynamic> cards;
  final int           required;
  const _ClientStats({required this.cards, required this.required});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatPill(
          label: 'Participantes',
          value: '${cards.length}',
          color: AppColors.primary,
          icon:  Icons.people_outline,
        ),
        const SizedBox(width: 8),
        _StatPill(
          label: 'Premio ganado',
          value: '${cards.where((c) => (c.programVisits as int? ?? 0) >= required).length}',
          color: Colors.amber.shade700,
          icon:  Icons.card_giftcard_outlined,
        ),
      ],
    );
  }
}

// ─── Botón "Ver clientes" ─────────────────────────────────────────────────────

class _ViewClientsButton extends StatelessWidget {
  final String programId;
  final String programName;
  const _ViewClientsButton({
    required this.programId,
    required this.programName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet<void>(
        context:            context,
        isScrollControlled: true,
        backgroundColor:    Colors.transparent,
        builder:            (_) => LoyaltyClientsSheet(
          programId:   programId,
          programName: programName,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color:        AppColors.primary.withAlpha(18),
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(color: AppColors.primary.withAlpha(50)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_alt_outlined, size: 14, color: AppColors.primary),
            SizedBox(width: 5),
            Text(
              'Ver clientes',
              style: TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w600,
                color:      AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String   label;
  final String   value;
  final Color    color;
  final IconData icon;
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:        color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(color: color.withAlpha(40)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize:   16,
                        fontWeight: FontWeight.bold,
                        color:      color)),
                Text(label,
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
