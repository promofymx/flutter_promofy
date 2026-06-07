import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:promofy/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';

/// Pantalla que se muestra cuando el usuario llega desde el enlace de
/// recuperación de contraseña del correo. Supabase abre la app con el
/// deep link `promofy:///auth/reset-password` después de intercambiar el token.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool    _obscure1 = true;
  bool    _obscure2 = true;
  bool    _loading  = false;
  bool    _success  = false;
  String? _error;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final res = await supabase.auth.updateUser(
        UserAttributes(password: _passCtrl.text.trim()),
      );
      if (res.user != null) {
        setState(() { _success = true; _loading = false; });
      } else {
        setState(() { _error = AppLocalizations.of(context).resetPwdUpdateError; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).resetPwdAppBarTitle),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: _success ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline_rounded,
              size: 44, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context).resetPwdSuccessTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context).resetPwdSuccessSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => context.go('/home'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Text(AppLocalizations.of(context).resetPwdGoHome,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).resetPwdFormTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).resetPwdFormHint,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_error!, style: const TextStyle(color: Color(0xFFC62828), fontSize: 13)),
            ),
            const SizedBox(height: 16),
          ],

          // Nueva contraseña
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure1,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).resetPwdNewLabel,
              suffixIcon: IconButton(
                icon: Icon(_obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                onPressed: () => setState(() => _obscure1 = !_obscure1),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().length < 6) return AppLocalizations.of(context).resetPwdMinLength;
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirmar
          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obscure2,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).resetPwdConfirmLabel,
              suffixIcon: IconButton(
                icon: Icon(_obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                onPressed: () => setState(() => _obscure2 = !_obscure2),
              ),
            ),
            validator: (v) {
              if (v != _passCtrl.text) return AppLocalizations.of(context).resetPwdMismatch;
              return null;
            },
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _loading ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(AppLocalizations.of(context).resetPwdSave,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
