import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/stamp_card_model.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../cubit/stamps_cubit.dart';
import '../cubit/stamps_state.dart';

class StampsScreen extends StatefulWidget {
  const StampsScreen({super.key});

  @override
  State<StampsScreen> createState() => _StampsScreenState();
}

class _StampsScreenState extends State<StampsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StampsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Visitas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (userId != null)
            IconButton(
              icon:    const Icon(Icons.qr_code_2),
              tooltip: 'Mi QR',
              onPressed: () => _showMyQr(context, userId),
            ),
        ],
      ),
      body: BlocBuilder<StampsCubit, StampsState>(
        builder: (context, state) {
          if (state is StampsLoading || state is StampsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StampsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<StampsCubit>().refresh(),
                    child:     const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is StampsLoaded) {
            if (state.cards.isEmpty) {
              return _EmptyState(
                userId: userId,
                onQrTap: userId != null
                    ? () => _showMyQr(context, userId)
                    : null,
              );
            }
            return _LoadedBody(
              cards:  state.cards,
              userId: userId,
              onQrTap: userId != null
                  ? () => _showMyQr(context, userId)
                  : null,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showMyQr(BuildContext context, String userId) {
    showModalBottomSheet<void>(
      context:       context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _MyQrSheet(userId: userId),
    );
  }
}

// ─── Cuerpo con tarjetas ──────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  final List<StampCardModel> cards;
  final String?              userId;
  final VoidCallback?        onQrTap;

  const _LoadedBody({required this.cards, this.userId, this.onQrTap});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<StampsCubit>().refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner de QR propio
          if (userId != null)
            _QrBannerTile(onTap: onQrTap),
          if (userId != null) const SizedBox(height: 12),

          ...cards.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child:   _StampCard(card: c),
              )),
        ],
      ),
    );
  }
}

// ─── Banner "Muestra tu QR" ───────────────────────────────────────────────────

class _QrBannerTile extends StatelessWidget {
  final VoidCallback? onTap;
  const _QrBannerTile({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withAlpha(180)],
            begin:  Alignment.topLeft,
            end:    Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.qr_code_2, color: Colors.white, size: 32),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mi código QR',
                      style: TextStyle(
                          color:      Colors.white,
                          fontSize:   15,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text('Muéstraselo al negocio para registrar tu visita.',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta de sello individual ─────────────────────────────────────────────

class _StampCard extends StatelessWidget {
  final StampCardModel card;
  const _StampCard({required this.card});

  static final _fmt = DateFormat('dd/MM/yyyy', 'es_MX');

  @override
  Widget build(BuildContext context) {
    final isRewardReady  = card.rewardReady;
    final isExpired      = card.programExpired;
    final isInactive     = !card.programIsActive;

    Color borderColor;
    if (isRewardReady) {
      borderColor = Colors.amber.shade600;
    } else if (isExpired || isInactive) {
      borderColor = Colors.grey.shade300;
    } else {
      borderColor = AppColors.primary.withAlpha(60);
    }

    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withAlpha(10),
              blurRadius: 6,
              offset:     const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Encabezado
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: card.establishmentLogo != null
                      ? CachedNetworkImage(
                          imageUrl:   card.establishmentLogo!,
                          width: 42, height: 42,
                          fit:        BoxFit.cover,
                        )
                      : Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color:        AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.store_outlined,
                              color: AppColors.primary, size: 22),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.establishmentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize:   14,
                              fontWeight: FontWeight.bold,
                              color:      AppColors.textDark)),
                      const SizedBox(height: 2),
                      Text(card.rewardDescription,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              color:    Colors.grey.shade600)),
                    ],
                  ),
                ),
                // Badge de estado
                _StatusBadge(
                  card:      card,
                  isExpired: isExpired,
                  isInactive: isInactive,
                ),
              ],
            ),
          ),

          // Sellos visuales
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
            child: _StampGrid(
              earned:   card.programVisits.clamp(0, card.visitsRequired),
              required: card.visitsRequired,
              faded:    isExpired || isInactive,
            ),
          ),

          // Barra de progreso
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${card.programVisits}/${card.visitsRequired} visitas',
                  style: TextStyle(
                    fontSize:   12,
                    fontWeight: FontWeight.w500,
                    color: isRewardReady
                        ? Colors.amber.shade700
                        : AppColors.primary,
                  ),
                ),
                Text(
                  'Total histórico: ${card.lifetimeVisits}',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (card.programVisits / card.visitsRequired).clamp(0.0, 1.0),
                minHeight:       6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isRewardReady ? Colors.amber.shade600 : AppColors.primary,
                ),
              ),
            ),
          ),

          // Pie: vigencia
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  isExpired || isInactive
                      ? Icons.timer_off_outlined
                      : Icons.event_outlined,
                  size:  13,
                  color: isExpired || isInactive
                      ? Colors.grey
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 5),
                Text(
                  isExpired || isInactive
                      ? 'Venció ${_fmt.format(card.programEndsAt)}'
                      : 'Vigente hasta ${_fmt.format(card.programEndsAt)}',
                  style: TextStyle(
                      fontSize: 11,
                      color: isExpired || isInactive
                          ? Colors.grey
                          : Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Grid de sellos ───────────────────────────────────────────────────────────

class _StampGrid extends StatelessWidget {
  final int  earned;
  final int  required;
  final bool faded;
  const _StampGrid({
    required this.earned,
    required this.required,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    // Máximo 10 sellos visibles por fila
    final show = required.clamp(1, 20);
    return Wrap(
      spacing:    8,
      runSpacing: 8,
      children: List.generate(show, (i) {
        final filled = i < earned;
        final color  = faded
            ? Colors.grey.shade400
            : (filled ? AppColors.primary : Colors.grey.shade200);
        return Container(
          width:  36,
          height: 36,
          decoration: BoxDecoration(
            color:  filled ? color.withAlpha(faded ? 40 : 30) : color,
            shape:  BoxShape.circle,
            border: Border.all(
              color: filled ? color : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.local_cafe_outlined,
            size:  18,
            color: filled ? color : Colors.grey.shade400,
          ),
        );
      }),
    );
  }
}

// ─── Badge de estado ──────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final StampCardModel card;
  final bool           isExpired;
  final bool           isInactive;
  const _StatusBadge({
    required this.card,
    required this.isExpired,
    required this.isInactive,
  });

  @override
  Widget build(BuildContext context) {
    if (card.rewardClaimed) {
      return _Badge(label: 'Canjeado', color: Colors.grey.shade500);
    }
    if (card.rewardReady) {
      return _Badge(label: '¡Premio!', color: Colors.amber.shade700);
    }
    if (isExpired || isInactive) {
      return _Badge(label: 'Terminado', color: Colors.grey.shade500);
    }
    return const SizedBox.shrink();
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color  color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withAlpha(80)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ─── QR propio (bottom-sheet) ─────────────────────────────────────────────────

class _MyQrSheet extends StatelessWidget {
  final String userId;
  const _MyQrSheet({required this.userId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
            const Text('Mi código QR',
                style: TextStyle(
                    fontSize:   20,
                    fontWeight: FontWeight.bold,
                    color:      AppColors.textDark)),
            const SizedBox(height: 8),
            Text(
              'Muéstrale este código al negocio para registrar tu visita.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color:      Colors.black.withAlpha(18),
                      blurRadius: 14,
                      offset:     const Offset(0, 4)),
                ],
              ),
              child: QrImageView(
                data:         userId,
                version:      QrVersions.auto,
                size:         220,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Código único de tu cuenta',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Vista vacía ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String?      userId;
  final VoidCallback? onQrTap;
  const _EmptyState({this.userId, this.onQrTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color:  AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.loyalty,
                  size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aún no tienes sellos',
              style: TextStyle(
                  fontSize:   20,
                  fontWeight: FontWeight.bold,
                  color:      AppColors.textDark),
            ),
            const SizedBox(height: 10),
            Text(
              'Visita negocios que tengan programa de lealtad '
              'y muéstrales tu código QR.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color:    Colors.grey.shade600,
                  height:   1.5),
            ),
            if (userId != null) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onQrTap,
                icon:  const Icon(Icons.qr_code_2),
                label: const Text('Ver mi QR',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
