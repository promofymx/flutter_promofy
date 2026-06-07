import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promofy/l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/stamp_card_model.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../cubit/stamps_cubit.dart';
import '../cubit/stamps_state.dart';

// ── Colores de sección ────────────────────────────────────────────────────────
const _kGold   = Color(0xFFFF8F00);
const _kBlue   = Color(0xFF1565C0);
const _kGreen  = Color(0xFF2E7D32);
const _kOrange = Color(0xFFE65100);

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
    final userId    = authState is AuthAuthenticated ? authState.user.id : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(AppLocalizations.of(context).stampsTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (userId != null)
            IconButton(
              icon:    const Icon(Icons.qr_code_2),
              tooltip: AppLocalizations.of(context).stampsMyQrTooltip,
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
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<StampsCubit>().refresh(),
            );
          }
          if (state is StampsLoaded) {
            if (state.cards.isEmpty) {
              return _EmptyState(
                userId:   userId,
                onQrTap:  userId != null
                    ? () => _showMyQr(context, userId)
                    : null,
              );
            }
            return _LoadedBody(cards: state.cards);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showMyQr(BuildContext context, String userId) {
    showModalBottomSheet<void>(
      context:            context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _MyQrSheet(userId: userId),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CUERPO PRINCIPAL — 3 secciones
// ═══════════════════════════════════════════════════════════════════════════════

class _LoadedBody extends StatefulWidget {
  final List<StampCardModel> cards;
  const _LoadedBody({required this.cards});

  @override
  State<_LoadedBody> createState() => _LoadedBodyState();
}

class _LoadedBodyState extends State<_LoadedBody> {
  bool _showAllClaimed = false;

  @override
  Widget build(BuildContext context) {
    // Clasificar tarjetas
    final ready    = widget.cards
        .where((c) => c.rewardReady)
        .toList();
    final progress = widget.cards
        .where((c) => !c.rewardClaimed && !c.rewardReady)
        .toList();
    final claimed  = widget.cards
        .where((c) => c.rewardClaimed)
        .toList();

    final claimedVisible = _showAllClaimed
        ? claimed
        : claimed.take(3).toList();

    return RefreshIndicator(
      onRefresh: () => context.read<StampsCubit>().refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Sección 1: Recompensas listas para canjear ─────────────────
          if (ready.isNotEmpty) ...[
            _SectionHeader(
              icon:  Icons.card_giftcard_rounded,
              label: AppLocalizations.of(context).stampsSectionReady,
              count: ready.length,
              color: _kGold,
              showCountBadge: true,
            ),
            const SizedBox(height: 10),
            ...ready.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child:   _ReadyCard(card: c),
            )),
            const SizedBox(height: 8),
          ],

          // ── Sección 2: En progreso ──────────────────────────────────────
          if (progress.isNotEmpty) ...[
            _SectionHeader(
              icon:   Icons.pending_actions_rounded,
              label:  AppLocalizations.of(context).stampsSectionInProgress,
              count:  progress.length,
              suffix: progress.length == 1
                  ? AppLocalizations.of(context).stampsSuffixProgram
                  : AppLocalizations.of(context).stampsSuffixPrograms,
              color:  AppColors.textDark,
            ),
            const SizedBox(height: 10),
            ...progress.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child:   _ProgressCard(card: c),
            )),
            const SizedBox(height: 8),
          ],

          // ── Sección 3: Recompensas ganadas ─────────────────────────────
          if (claimed.isNotEmpty) ...[
            _SectionHeader(
              icon:   Icons.emoji_events_rounded,
              label:  AppLocalizations.of(context).stampsSectionEarned,
              count:  claimed.length,
              suffix: AppLocalizations.of(context).stampsSuffixTotal,
              color:  _kGreen,
            ),
            const SizedBox(height: 10),
            ...claimedVisible.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child:   _ClaimedTile(card: c),
            )),
            if (claimed.length > 3 && !_showAllClaimed) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => setState(() => _showAllClaimed = true),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).stampsSeeAllRewards,
                    style: const TextStyle(
                      color:      AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize:   14,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGETS DE SECCIÓN
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String   label;
  final int      count;
  final String?  suffix;
  final Color    color;
  final bool     showCountBadge;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.count,
    this.suffix,
    required this.color,
    this.showCountBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: TextStyle(
                fontSize:   14,
                fontWeight: FontWeight.w700,
                color:      color,
              )),
        ),
        if (showCountBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color:        color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(color: color.withAlpha(80)),
            ),
            child: Text('$count',
                style: TextStyle(
                  fontSize:   12,
                  fontWeight: FontWeight.bold,
                  color:      color,
                )),
          )
        else if (suffix != null)
          Text('$count $suffix',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TARJETA: LISTA PARA CANJEAR (dorada)
// ═══════════════════════════════════════════════════════════════════════════════

class _ReadyCard extends StatelessWidget {
  final StampCardModel card;
  const _ReadyCard({required this.card});

  String get _daysLeft {
    final days = card.programEndsAt.difference(DateTime.now()).inDays;
    if (days <= 0) return 'Caduca hoy';
    return 'Caduca en $days ${days == 1 ? 'día' : 'días'}';
  }

  void _openRedemptionQr(BuildContext context) {
    showModalBottomSheet<void>(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder:            (_) => _RedemptionQrSheet(card: card),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openRedemptionQr(context),
      child: Container(
        decoration: BoxDecoration(
          color:        const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: _kGold.withAlpha(100)),
          boxShadow: [
            BoxShadow(
              color:      _kGold.withAlpha(35),
              blurRadius: 10,
              offset:     const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Logo + nombre + descripción ───────────────────────
                  Row(
                    children: [
                      _Avatar(logo: card.establishmentLogo, color: _kGold, size: 50),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.establishmentName,
                              style: const TextStyle(
                                fontSize:   15,
                                fontWeight: FontWeight.bold,
                                color:      AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Text('🎁 ', style: TextStyle(fontSize: 13)),
                                Expanded(
                                  child: Text(
                                    card.rewardDescription,
                                    style: const TextStyle(
                                      fontSize:   13,
                                      fontWeight: FontWeight.w600,
                                      color:      _kGold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Espacio para el badge "¡LISTA!"
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Botón QR ──────────────────────────────────────────
                  Container(
                    width:   double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:        Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border:       Border.all(color: _kGold.withAlpha(90)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_2, size: 18, color: _kGold),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context).stampsTapForRedemptionQr,
                            style: const TextStyle(
                              fontSize:   13,
                              fontWeight: FontWeight.w600,
                              color:      _kGold,
                            )),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right,
                            size: 16, color: _kGold.withAlpha(160)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Caducidad ─────────────────────────────────────────
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 12, color: _kGold.withAlpha(180)),
                      const SizedBox(width: 4),
                      Text(_daysLeft,
                          style: TextStyle(
                            fontSize: 11,
                            color:    _kGold.withAlpha(200),
                          )),
                    ],
                  ),
                ],
              ),
            ),

            // ── Badge "¡LISTA!" ───────────────────────────────────────────
            Positioned(
              top:   0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: const BoxDecoration(
                  color:        _kGold,
                  borderRadius: BorderRadius.only(
                    topRight:    Radius.circular(16),
                    bottomLeft:  Radius.circular(10),
                  ),
                ),
                child: Text(AppLocalizations.of(context).stampsReadyBadge,
                    style: const TextStyle(
                      fontSize:      10,
                      fontWeight:    FontWeight.bold,
                      color:         Colors.white,
                      letterSpacing: 0.8,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TARJETA: EN PROGRESO (azul — visitas)
// ═══════════════════════════════════════════════════════════════════════════════

class _ProgressCard extends StatelessWidget {
  final StampCardModel card;
  const _ProgressCard({required this.card});

  static final _fmt = DateFormat('dd/MM/yyyy', 'es_MX');

  bool get _inactive => !card.programIsActive || card.programExpired;

  Color get _accent => _inactive ? Colors.grey.shade400 : _kBlue;

  @override
  Widget build(BuildContext context) {
    final faded  = _inactive;
    final accent = _accent;

    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: faded ? Colors.grey.shade200 : _kBlue.withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withAlpha(10),
            blurRadius: 6,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                _Avatar(logo: card.establishmentLogo, color: accent, size: 46),
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
                            color:      AppColors.textDark,
                          )),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Text('🎁 ', style: TextStyle(fontSize: 12)),
                          Expanded(
                            child: Text(card.rewardDescription,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:    Colors.grey.shade600,
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (faded)
                  _MiniChip(
                      label: AppLocalizations.of(context).stampsFinished,
                      color: Colors.grey.shade500),
              ],
            ),
          ),

          // ── Grid de sellos ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: _StampGrid(
              earned:   card.programVisits.clamp(0, card.visitsRequired),
              required: card.visitsRequired,
              color:    accent,
            ),
          ),

          // ── Contador + texto motivacional ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context).stampsVisitsCount(
                      card.programVisits, card.visitsRequired),
                  style: TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                    color:      accent,
                  ),
                ),
                const Spacer(),
                if (!faded && card.stampsLeft > 0)
                  Text(
                    AppLocalizations.of(context).stampsStampsLeft(card.stampsLeft),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:    Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),

          // ── Pie: caducidad ────────────────────────────────────────────
          Container(
            margin:  const EdgeInsets.fromLTRB(14, 8, 14, 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color:        faded
                  ? Colors.grey.shade50
                  : _kBlue.withAlpha(12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  faded
                      ? Icons.timer_off_outlined
                      : Icons.event_outlined,
                  size:  12,
                  color: faded ? Colors.grey : _kBlue.withAlpha(180),
                ),
                const SizedBox(width: 5),
                Text(
                  faded
                      ? AppLocalizations.of(context)
                          .stampsExpiredOn(_fmt.format(card.programEndsAt))
                      : AppLocalizations.of(context)
                          .stampsExpiresOn(_fmt.format(card.programEndsAt)),
                  style: TextStyle(
                    fontSize: 11,
                    color: faded ? Colors.grey : _kBlue.withAlpha(180),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TILE: RECOMPENSA CANJEADA (verde)
// ═══════════════════════════════════════════════════════════════════════════════

class _ClaimedTile extends StatelessWidget {
  final StampCardModel card;
  const _ClaimedTile({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _Avatar(logo: card.establishmentLogo, color: _kGreen, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.establishmentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w600,
                    color:      AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  card.rewardDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _MiniChip(
              label: AppLocalizations.of(context).stampsRedeemed,
              color: _kGreen),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GRID DE SELLOS
// ═══════════════════════════════════════════════════════════════════════════════

class _StampGrid extends StatelessWidget {
  final int   earned;
  final int   required;
  final Color color;

  const _StampGrid({
    required this.earned,
    required this.required,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final show = required.clamp(1, 20);
    return Wrap(
      spacing:    8,
      runSpacing: 8,
      children: List.generate(show, (i) {
        final filled = i < earned;
        return Container(
          width:  34,
          height: 34,
          decoration: BoxDecoration(
            color:  filled ? color.withAlpha(25) : Colors.grey.shade100,
            shape:  BoxShape.circle,
            border: Border.all(
              color: filled ? color : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Icon(
            filled ? Icons.check_rounded : Icons.circle_outlined,
            size:  16,
            color: filled ? color : Colors.grey.shade300,
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BOTTOM-SHEET: QR DE CANJE DE RECOMPENSA
// ═══════════════════════════════════════════════════════════════════════════════

class _RedemptionQrSheet extends StatelessWidget {
  final StampCardModel card;
  const _RedemptionQrSheet({required this.card});

  static final _fmtLong = DateFormat("dd 'de' MMMM yyyy", 'es_MX');

  /// Código alfanumérico corto — primeros 8 chars del card UUID en 2 grupos.
  String get _shortCode {
    final hex = card.id.replaceAll('-', '').toUpperCase();
    return '${hex.substring(0, 4)}-${hex.substring(4, 8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width:  40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                decoration: BoxDecoration(
                  color:        Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Banner naranja ────────────────────────────────────────
              Container(
                width:   double.infinity,
                margin:  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color:        _kOrange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  AppLocalizations.of(context).stampsRedeemReward,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color:      Colors.white,
                    fontSize:   16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ── Premio + establecimiento ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      card.rewardDescription.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize:      12,
                        fontWeight:    FontWeight.w700,
                        letterSpacing: 1.2,
                        color:         _kOrange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)
                              .stampsAtEstablishment(card.establishmentName),
                          style: const TextStyle(
                            fontSize:   18,
                            fontWeight: FontWeight.bold,
                            color:      AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── QR ──────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:        const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(16),
                        border:       Border.all(
                          color: _kOrange.withAlpha(80),
                          width: 2,
                        ),
                      ),
                      child: QrImageView(
                        data:    card.id,
                        version: QrVersions.auto,
                        size:    200,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Código alfanumérico ──────────────────────────────
                    Text(
                      AppLocalizations.of(context).stampsCodeLabel(_shortCode),
                      style: const TextStyle(
                        fontSize:      13,
                        fontWeight:    FontWeight.w700,
                        color:         _kOrange,
                        letterSpacing: 1.5,
                        fontFamily:    'monospace',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Instrucción ──────────────────────────────────────
                    Text(
                      AppLocalizations.of(context).stampsShowCodeToStaff,
                      style: const TextStyle(
                        fontSize:   14,
                        fontWeight: FontWeight.w600,
                        color:      AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).stampsStaffWillScan,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 16),

                    // ── Caducidad ────────────────────────────────────────
                    Container(
                      width:   double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color:        const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kOrange.withAlpha(60)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer_outlined,
                              size: 14, color: _kOrange),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context)
                                .stampsExpiresOn(_fmtLong.format(card.programEndsAt)),
                            style: const TextStyle(
                              fontSize:   12,
                              fontWeight: FontWeight.w500,
                              color:      _kOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BOTTOM-SHEET: QR PROPIO (para que el negocio registre visitas)
// ═══════════════════════════════════════════════════════════════════════════════

class _MyQrSheet extends StatelessWidget {
  final String userId;
  const _MyQrSheet({required this.userId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width:  40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color:        Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(AppLocalizations.of(context).stampsMyQrTitle,
                style: const TextStyle(
                  fontSize:   20,
                  fontWeight: FontWeight.bold,
                  color:      AppColors.textDark,
                )),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).stampsMyQrSubtitle,
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
                    offset:     const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data:    userId,
                version: QrVersions.auto,
                size:    220,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).stampsUniqueAccountCode,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ═══════════════════════════════════════════════════════════════════════════════

class _Avatar extends StatelessWidget {
  final String? logo;
  final Color   color;
  final double  size;
  const _Avatar({this.logo, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.22);
    if (logo != null) {
      return ClipRRect(
        borderRadius: radius,
        child: CachedNetworkImage(
          imageUrl: logo!,
          width:    size,
          height:   size,
          fit:      BoxFit.cover,
        ),
      );
    }
    return Container(
      width:  size,
      height: size,
      decoration: BoxDecoration(
        color:        color.withAlpha(20),
        borderRadius: radius,
      ),
      child: Icon(Icons.store_outlined, color: color, size: size * 0.44),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color  color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withAlpha(70)),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize:   10,
            fontWeight: FontWeight.w600,
            color:      color,
          )),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String      message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).stampsRetry),
            ),
          ],
        ),
      ),
    );
  }
}

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
              width:  96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.loyalty,
                  size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).stampsEmptyTitle,
              style: const TextStyle(
                fontSize:   20,
                fontWeight: FontWeight.bold,
                color:      AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context).stampsEmptyMsg,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color:    Colors.grey.shade600,
                height:   1.5,
              ),
            ),
            if (userId != null) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onQrTap,
                icon:  const Icon(Icons.qr_code_2),
                label: Text(AppLocalizations.of(context).stampsViewMyQr,
                    style: const TextStyle(
                      fontSize:   15,
                      fontWeight: FontWeight.w600,
                    )),
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
