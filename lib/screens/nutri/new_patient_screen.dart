import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/cloud_repository.dart';
import '../../models/meal_plan.dart';
import '../../services/auth_service.dart';

/// Cadastro de paciente: cria o login (e-mail + senha provisória).
class NewPatientScreen extends StatefulWidget {
  const NewPatientScreen({super.key, required this.repo});

  final CloudRepository repo;

  @override
  State<NewPatientScreen> createState() => _NewPatientScreenState();
}

class _NewPatientScreenState extends State<NewPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  late final _password = TextEditingController(text: _generatePassword());
  bool _busy = false;

  static String _generatePassword() {
    const chars = 'abcdefghjkmnpqrstuvwxyz23456789';
    final rnd = Random.secure();
    return List.generate(8, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await widget.repo.createPatient(
        name: _name.text.trim(),
        email: _email.text.trim().toLowerCase(),
        temporaryPassword: _password.text,
        initialPlan: MealPlan.empty(patientName: _name.text.trim()),
      );
      if (!mounted) return;
      await _showCredentials();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AuthService.describe(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showCredentials() {
    final message = 'Olá, ${_name.text.trim()}! Seu acesso ao Nutri App:\n'
        'E-mail: ${_email.text.trim().toLowerCase()}\n'
        'Senha provisória: ${_password.text}\n'
        'Depois de entrar, troque a senha em Configurações.';
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paciente cadastrado'),
        content: SelectableText(message),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copiado.')));
            },
            child: const Text('Copiar mensagem'),
          ),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo paciente')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) => (v ?? '').trim().isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail do paciente'),
              validator: (v) => (v ?? '').contains('@') ? null : 'E-mail inválido',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              decoration: InputDecoration(
                labelText: 'Senha provisória',
                suffixIcon: IconButton(
                  tooltip: 'Gerar outra',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => setState(() => _password.text = _generatePassword()),
                ),
              ),
              validator: (v) => (v ?? '').length < 6 ? 'Mínimo de 6 caracteres' : null,
            ),
            const SizedBox(height: 8),
            Text(
              'Depois de criar, envie o e-mail e a senha para o paciente (ex.: pelo WhatsApp). '
              'Em seguida monte o cardápio dele.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _create,
              child: _busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Criar acesso'),
            ),
          ],
        ),
      ),
    );
  }
}
