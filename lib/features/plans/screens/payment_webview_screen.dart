import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:promofy/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

enum PaymentResult { success, failure, pending, cancelled }

/// Pantalla WebView que carga el checkout de MercadoPago.
/// Intercepta la URL de retorno (promofy://) para detectar el resultado.
///
/// Uso:
/// ```dart
/// final result = await Navigator.of(context).push<PaymentResult>(
///   MaterialPageRoute(builder: (_) => PaymentWebViewScreen(checkoutUrl: url)),
/// );
/// ```
class PaymentWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String title;

  const PaymentWebViewScreen({
    super.key,
    required this.checkoutUrl,
    this.title = 'Pago seguro',
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _ctrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // En web: abrir en pestaña del navegador y cerrar esta pantalla
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await launchUrl(Uri.parse(widget.checkoutUrl),
            mode: LaunchMode.externalApplication);
        if (mounted) Navigator.of(context).pop(PaymentResult.pending);
      });
      return;
    }
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onWebResourceError: (err) {
            // ignorar errores de recursos secundarios (iframes, ads, etc.)
            if (err.isForMainFrame ?? false) {
              setState(() => _loading = false);
            }
          },
          onNavigationRequest: (req) {
            final url = req.url;
            // Interceptar la URL de retorno de MercadoPago
            if (url.startsWith('promofy://')) {
              final result = _resolveResult(url);
              Navigator.of(context).pop(result);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  PaymentResult _resolveResult(String url) {
    if (url.contains('/success')) return PaymentResult.success;
    if (url.contains('/failure')) return PaymentResult.failure;
    if (url.contains('/pending')) return PaymentResult.pending;
    // back_url sin path (suscripciones) → pendiente hasta webhook
    return PaymentResult.pending;
  }

  @override
  Widget build(BuildContext context) {
    // En web mostramos pantalla de espera mientras se abre el navegador
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).paymentSecureTitle),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(PaymentResult.cancelled),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context).paymentOpeningBrowser),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.lock_outline, size: 16, color: Colors.green),
            const SizedBox(width: 6),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: AppLocalizations.of(context).paymentCancelTooltip,
          onPressed: () => Navigator.of(context).pop(PaymentResult.cancelled),
        ),
        bottom: _loading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : null,
      ),
      body: WebViewWidget(controller: _ctrl),
    );
  }
}
