import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/loyalty_client_model.dart';
import '../../../data/repositories/loyalty_repository.dart';

/// Bottom-sheet que muestra dos tablas de clientes para un programa de lealtad:
///   1. Progreso en el programa actual (ordenado por visitas desc)
///   2. Historial de comensales de todos los tiempos (más frecuentes primero)
class LoyaltyClientsSheet extends StatefulWidget {
  final String programId;
  final String programName;

  const LoyaltyClientsSheet({
    super.key,
    required this.programId,
    required this.programName,
  });

  @override
  State<LoyaltyClientsSheet> createState() => _LoyaltyClientsSheetState();
}

class _LoyaltyClientsSheetState extends State<LoyaltyClientsSheet> {
  final _repo = LoyaltyRepository();

  late Future<LoyaltyClientsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getClients(widget.programId);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize:     0.5,
      maxChildSize:     0.95,
      expand:           false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color:        Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Título
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    const Icon(Icons.people_rounded,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Mis clientes',
                        style: TextStyle(
                          fontSize:   17,
                          fontWeight: FontWeight.bold,
                          color:      AppColors.textDark,
                        ),
                      ),
                    ),
                    IconButton(
                      icon:      const Icon(Icons.close, size: 20),
                      color:     Colors.grey.shade400,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Contenido
              Expanded(
                child: FutureBuilder<LoyaltyClientsData>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2.5,
                        ),
                      );
                    }
                    if (snap.hasError || !snap.hasData) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.grey.shade400, size: 36),
                            const SizedBox(height: 8),
                            Text(
                              'No se pudieron cargar los clientes.',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => setState(
                                () => _future = _repo.getClients(widget.programId),
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    final data = snap.data!;
                    return ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        _ProgramProgressTable(data: data),
                        const SizedBox(height: 24),
                        _HistoricalTable(data: data),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Tabla 1: Progreso en el programa actual ──────────────────────────────────

class _ProgramProgressTable extends StatelessWidget {
  final LoyaltyClientsData data;
  const _ProgramProgressTable({required this.data});

  @override
  Widget build(BuildContext context) {
    final clients = data.currentProgram;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header sección
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color:        AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.loyalty, size: 13, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    'PROGRAMA ACTUAL',
                    style: TextStyle(
                      fontSize:    10,
                      fontWeight:  FontWeight.w700,
                      color:       AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${clients.length} participante${clients.length != 1 ? "s" : ""}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (clients.isEmpty)
          const _EmptyHint(
            icon:    Icons.person_search_outlined,
            message: 'Aún no hay clientes en este programa. '
                     'Escanea el QR de tus primeros visitantes.',
          )
        else
          ...clients.map((c) => _ProgressRow(client: c)),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final LoyaltyClientProgressModel client;
  const _ProgressRow({required this.client});

  @override
  Widget build(BuildContext context) {
    final color = client.rewardReady
        ? Colors.amber.shade700
        : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar inicial
              Container(
                width: 32, height: 32,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color:  color.withAlpha(25),
                  shape:  BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  client.clientName.isNotEmpty
                      ? client.clientName[0].toUpperCase()
                      : 'C',
                  style: TextStyle(
                    fontSize:   14,
                    fontWeight: FontWeight.bold,
                    color:      color,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            client.clientName,
                            style: const TextStyle(
                              fontSize:   13,
                              fontWeight: FontWeight.w500,
                              color:      AppColors.textDark,
                            ),
                          ),
                        ),
                        // Badge de premio
                        if (client.rewardReady)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color:        Colors.amber.shade700.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.card_giftcard,
                                    size: 11, color: Colors.amber.shade700),
                                const SizedBox(width: 3),
                                Text(
                                  '¡Premio!',
                                  style: TextStyle(
                                    fontSize:   10,
                                    fontWeight: FontWeight.w600,
                                    color:      Colors.amber.shade700,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            '${client.stampsLeft} para su premio',
                            style: TextStyle(
                              fontSize: 11,
                              color:    Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Barra de progreso
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value:           client.progress,
                              minHeight:       6,
                              backgroundColor: Colors.grey.shade200,
                              valueColor:      AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${client.programVisits}/${client.visitsRequired}',
                          style: TextStyle(
                            fontSize:   11,
                            fontWeight: FontWeight.w600,
                            color:      color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Tabla 2: Historial de comensales ─────────────────────────────────────────

class _HistoricalTable extends StatelessWidget {
  final LoyaltyClientsData data;
  const _HistoricalTable({required this.data});

  @override
  Widget build(BuildContext context) {
    final clients = data.historical;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header sección
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color:        AppColors.secondary.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.leaderboard_rounded, size: 13, color: AppColors.secondary),
              SizedBox(width: 4),
              Text(
                'HISTORIAL DE COMENSALES',
                style: TextStyle(
                  fontSize:    10,
                  fontWeight:  FontWeight.w700,
                  color:       AppColors.secondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Total de visitas registradas con QR, de mayor a menor.',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, height: 1.3),
        ),
        const SizedBox(height: 12),

        if (clients.isEmpty)
          const _EmptyHint(
            icon:    Icons.history_toggle_off,
            message: 'El historial aparecerá aquí conforme escanees '
                     'a tus clientes con QR.',
          )
        else ...[
          // Encabezado de columnas
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(width: 28),  // espacio del ranking
                SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Cliente',
                    style: TextStyle(
                      fontSize:   10,
                      fontWeight: FontWeight.w600,
                      color:      AppColors.textDark,
                    ),
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    'Visitas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:   10,
                      fontWeight: FontWeight.w600,
                      color:      AppColors.textDark,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Gasto',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize:   10,
                      fontWeight: FontWeight.w600,
                      color:      AppColors.textDark,
                    ),
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    'Última',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize:   10,
                      fontWeight: FontWeight.w600,
                      color:      AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 6),

          ...clients.asMap().entries.map(
            (e) => _HistoryRow(rank: e.key + 1, client: e.value),
          ),
        ],
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final int                      rank;
  final LoyaltyClientHistoryModel client;
  const _HistoryRow({required this.rank, required this.client});

  Color get _rankColor {
    if (rank == 1) return const Color(0xFFFFD700);  // oro
    if (rank == 2) return const Color(0xFFC0C0C0);  // plata
    if (rank == 3) return const Color(0xFFCD7F32);  // bronce
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ranking
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color:  _rankColor.withAlpha(40),
              shape:  BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize:   11,
                fontWeight: FontWeight.bold,
                color:      rank <= 3 ? _rankColor : Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Nombre
          Expanded(
            flex: 3,
            child: Text(
              client.clientName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize:   13,
                color:      AppColors.textDark,
              ),
            ),
          ),

          // Visitas
          SizedBox(
            width: 56,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:        AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${client.totalVisits}',
                  textAlign:  TextAlign.center,
                  style: const TextStyle(
                    fontSize:   12,
                    fontWeight: FontWeight.bold,
                    color:      AppColors.primary,
                  ),
                ),
              ),
            ),
          ),

          // Gasto
          SizedBox(
            width: 60,
            child: Text(
              client.formattedSpent,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color:    client.totalSpent != null && client.totalSpent! > 0
                    ? Colors.green.shade700
                    : Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Última visita
          SizedBox(
            width: 52,
            child: Text(
              client.formattedLastVisit,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hint vacío ───────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String   message;
  const _EmptyHint({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.grey.shade300),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color:    Colors.grey.shade500,
                height:   1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
