import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

/// Tela de entrada. Pacientes recebem e-mail e senha da nutricionista.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _registerMode = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      if (_registerMode) {
        await widget.auth.register(_email.text, _password.text);
      } else {
        await widget.auth.signIn(_email.text, _password.text);
      }
    } catch (e) {
      if (mounted) _snack(AuthService.describe(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (!_email.text.contains('@')) {
      _snack('Digite seu e-mail no campo acima primeiro.');
      return;
    }
    try {
      await widget.auth.sendPasswordReset(_email.text);
      if (mounted) _snack('Enviamos um link para redefinir a senha no seu e-mail.');
    } catch (e) {
      if (mounted) _snack(AuthService.describe(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/icon/logo_mark.png', height: 88),
                    const SizedBox(height: 16),
                    Text('Nutri App', textAlign: TextAlign.center, style: text.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      _registerMode
                          ? 'Primeiro acesso da nutricionista'
                          : 'Seu acompanhamento nutricional',
                      textAlign: TextAlign.center,
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.mail_outline)),
                      validator: (v) => (v ?? '').contains('@') ? null : 'E-mail inválido',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: !_showPassword,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      validator: (v) => (v ?? '').length < 6 ? 'Mínimo de 6 caracteres' : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _busy
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(_registerMode ? 'Criar conta' : 'Entrar'),
                      ),
                    ),
                    if (!_registerMode)
                      TextButton(onPressed: _forgotPassword, child: const Text('Esqueci minha senha')),
                    const SizedBox(height: 24),
                    if (!_registerMode)
                      Text(
                        'Paciente: use o e-mail e a senha que sua nutricionista enviou.',
                        textAlign: TextAlign.center,
                        style: text.bodySmall,
                      ),
                    TextButton(
                      onPressed: () => setState(() => _registerMode = !_registerMode),
                      child: Text(_registerMode ? 'Voltar para o login' : 'Sou a nutricionista e é meu primeiro acesso'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
