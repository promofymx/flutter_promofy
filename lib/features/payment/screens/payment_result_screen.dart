import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:promofy/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

enum PaymentResult { success, failure, pending, subscriptionCallback }

class PaymentResultScreen extends StatelessWidget {
  final PaymentResult result;
  const PaymentResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final cfg = _config(result, context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width:  100,
                height: 100,
                decoration: BoxDecoration(
                  color: cfg.bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(cfg.icon, size: 52, color: cfg.iconColor),
              ),
              const SizedBox(height: 28),
              Text(
                cfg.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize:   22,
                  fontWeight: FontWeight.w800,
                  color:      AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                cfg.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color:    Colors.grey.shade600,
                  height:   1.5,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize:     const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context).paymentResultGoHome,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              if (result == PaymentResult.failure) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/business'),
                  child: Text(
                    AppLocalizations.of(context).paymentResultTryAgain,
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _Cfg _config(PaymentResult r, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (r) {
      case PaymentResult.success:
        return _Cfg(
          icon:      Icons.check_circle_outline_rounded,
          iconColor: const Color(0xFF2E7D32),
          bgColor:   const Color(0xFFE8F5E9),
          title:     l10n.paymentResultSuccessTitle,
          subtitle:  l10n.paymentResultSuccessSubtitle,
        );
      case PaymentResult.failure:
        return _Cfg(
          icon:      Icons.cancel_outlined,
          iconColor: const Color(0xFFC62828),
          bgColor:   const Color(0xFFFFEBEE),
          title:     l10n.paymentResultFailureTitle,
          subtitle:  l10n.paymentResultFailureSubtitle,
        );
      case PaymentResult.pending:
        return _Cfg(
          icon:      Icons.schedule_rounded,
          iconColor: const Color(0xFFE65100),
          bgColor:   const Color(0xFFFFF3E0),
          title:     l10n.paymentResultPendingTitle,
          subtitle:  l10n.paymentResultPendingSubtitle,
        );
      case PaymentResult.subscriptionCallback:
        return _Cfg(
          icon:      Icons.verified_outlined,
          iconColor: AppColors.primary,
          bgColor:   AppColors.primary.withAlpha(25),
          title:     l10n.paymentResultSubscriptionTitle,
          subtitle:  l10n.paymentResultSubscriptionSubtitle,
        );
    }
  }
}

class _Cfg {
  final IconData icon;
  final Color    iconColor;
  final Color    bgColor;
  final String   title;
  final String   subtitle;
  const _Cfg({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
  });
}
