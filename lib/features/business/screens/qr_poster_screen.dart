import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/establishment_model.dart';

/// Cartel imprimible (media carta vertical) con el QR del establecimiento.
/// El QR apunta a promofy.fun/e/<id> (abre la app si está instalada; si no, la
/// página web del negocio con botón de descarga). Lleva el logo de Promofy al
/// centro del QR para conservar marca aunque recorten el cartel.
class QrPosterScreen extends StatefulWidget {
  final EstablishmentModel establishment;
  const QrPosterScreen({super.key, required this.establishment});

  @override
  State<QrPosterScreen> createState() => _QrPosterScreenState();
}

class _QrPosterScreenState extends State<QrPosterScreen> {
  final _posterKey = GlobalKey();
  bool _busy = false;

  String get _url => 'https://promofy.fun/e/${widget.establishment.id}';

  Future<void> _exportar({required bool compartir}) async {
    setState(() => _busy = true);
    try {
      // Esperar un frame para asegurar que el QR/imágenes estén renderizadas.
      await Future<void>.delayed(const Duration(milliseconds: 120));
      final boundary = _posterKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.5); // alta resolución para imprimir
      final data  = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw 'No se pudo generar la imagen';
      final bytes = data.buffer.asUint8List();

      final safeName = widget.establishment.name
          .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
      final file = File('${Directory.systemTemp.path}/Promofy_QR_$safeName.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'QR de ${widget.establishment.name} para Promofy 📲',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo generar el QR: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        title: const Text('QR de tu negocio',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Material(
                  elevation: 6,
                  child: RepaintBoundary(
                    key: _posterKey,
                    child: _Poster(
                      establishment: widget.establishment,
                      url: _url,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : () => _exportar(compartir: true),
                      icon: _busy
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.ios_share_rounded, size: 18),
                      label: Text(_busy ? 'Generando…' : 'Descargar / Compartir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cartel (media carta vertical 5.5" x 8.5") ────────────────────────────────

class _Poster extends StatelessWidget {
  final EstablishmentModel establishment;
  final String url;
  const _Poster({required this.establishment, required this.url});

  @override
  Widget build(BuildContext context) {
    final hasLogo = (establishment.logoUrl ?? '').isNotEmpty;
    // Ancho fijo + proporción media carta vertical (5.5:8.5).
    return Container(
      width: 380,
      color: Colors.white,
      child: AspectRatio(
        aspectRatio: 5.5 / 8.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            children: [
              // ── Marca Promofy ───────────────────────────────────────────
              Image.asset('assets/images/logo.png', height: 40),
              const SizedBox(height: 2),
              const Text('Promofy',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.5)),

              const SizedBox(height: 14),
              // ── Logo del establecimiento (si tiene) + nombre ────────────
              if (hasLogo) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: establishment.logoUrl!,
                    width: 64, height: 64, fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                establishment.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),

              const SizedBox(height: 12),
              // ── Invitación (estilo "síguenos") ──────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('⭐ Síguenos en Promofy',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ),

              const Spacer(),
              // ── QR con logo de Promofy al centro ────────────────────────
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: QrImageView(
                  data: url,
                  version: QrVersions.auto,
                  size: 190,
                  gapless: false,
                  errorCorrectionLevel: QrErrorCorrectLevel.H, // tolera el logo al centro
                  eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square, color: Color(0xFF1A1A1A)),
                  dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF1A1A1A)),
                  embeddedImage: const AssetImage('assets/images/logo.png'),
                  embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(46, 46)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('📷 Escanea con la cámara de tu teléfono',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text(
                'Agréganos a favoritos y entérate de\ntodas nuestras promociones 🔔',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600, height: 1.35),
              ),
              const Spacer(),
              Text('promofy.fun',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
