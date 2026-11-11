import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/cloud_repository.dart';
import '../../data/local_storage.dart';
import '../../models/chat_message.dart';
import '../../models/food.dart';
import '../../services/auth_service.dart';
import '../../services/reminder_service.dart';
import '../../state/app_state.dart';
import '../home_shell.dart';
import '../nutri/nutri_home_screen.dart';
import 'login_screen.dart';

enum _Role { nutritionist, patient, unverifiedNutritionist, notRegistered, notConfigured }

/// Decide o que mostrar conforme o login: tela de login, app do paciente ou
/// área da nutricionista.
class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.auth,
    required this.repo,
    required this.storage,
    required this.foods,
    required this.reminders,
  });

  final AuthService auth;
  final CloudRepository repo;
  final LocalStorage storage;
  final List<Food> foods;
  final LocalReminderService reminders;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: auth.userChanges(),
      initialData: auth.currentUser,
      builder: (context, snap) {
        final user = snap.data;
        if (user == null) return LoginScreen(auth: auth);
        return _RoleRouter(
          key: ValueKey('${user.uid}-${user.emailVerified}'),
          user: user,
          gate: this,
        );
      },
    );
  }
}

class _RoleRouter extends StatefulWidget {
  const _RoleRouter({super.key, required this.user, required this.gate});

  final User user;
  final AuthGate gate;

  @override
  State<_RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<_RoleRouter> {
  late Future<_Role> _role = _resolve();

  Future<_Role> _resolve() async {
    final repo = widget.gate.repo;
    final nutriEmail = await repo.nutritionistEmail();
    final email = widget.user.email?.toLowerCase();
    if (nutriEmail != null && email == nutriEmail.toLowerCase()) {
      return widget.user.emailVerified ? _Role.nutritionist : _Role.unverifiedNutritionist;
    }
    if (await repo.patientExists(widget.user.uid)) return _Role.patient;
    return nutriEmail == null ? _Role.notConfigured : _Role.notRegistered;
  }

  void _retry() => setState(() => _role = _resolve());

  @override
  Widget build(BuildContext context) {
    final gate = widget.gate;
    return FutureBuilder<_Role>(
      future: _role,
      builder: (context, snap) {
        if (snap.hasError) {
          return _MessageScreen(
            icon: Icons.wifi_off,
            title: 'Não foi possível conectar',
            message: 'Verifique sua internet e tente novamente.',
            primary: ('Tentar novamente', _retry),
            auth: gate.auth,
          );
        }
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return switch (snap.data!) {
          _Role.nutritionist => NutriHomeScreen(auth: gate.auth, repo: gate.repo),
          _Role.patient => _PatientSession(user: widget.user, gate: gate),
          _Role.unverifiedNutritionist => _MessageScreen(
              icon: Icons.mark_email_unread_outlined,
              title: 'Confirme seu e-mail',
              message: 'Enviamos um link de confirmação para ${widget.user.email}. '
                  'Abra o e-mail, toque no link e depois volte aqui.',
              primary: ('Já confirmei', () async {
                await gate.auth.refresh();
                _retry();
              }),
              secondary: ('Reenviar e-mail', () => gate.auth.sendVerificationEmail()),
              auth: gate.auth,
            ),
          _Role.notRegistered => _MessageScreen(
              icon: Icons.person_off_outlined,
              title: 'Conta sem cadastro',
              message: 'Esta conta ainda não foi cadastrada pela nutricionista. '
                  'Peça para ela criar seu acesso no app.',
              primary: ('Tentar novamente', _retry),
              auth: gate.auth,
            ),
          _Role.notConfigured => _MessageScreen(
              icon: Icons.settings_outlined,
              title: 'App ainda não configurado',
              message: 'O e-mail da nutricionista não foi cadastrado no Firebase '
                  '(documento config/clinic). Veja docs/FIREBASE.md.',
              primary: ('Tentar novamente', _retry),
              auth: gate.auth,
            ),
        };
      },
    );
  }
}

/// Sessão do paciente: cria o estado e liga aos dados da nuvem.
class _PatientSession extends StatefulWidget {
  const _PatientSession({required this.user, required this.gate});

  final User user;
  final AuthGate gate;

  @override
  State<_PatientSession> createState() => _PatientSessionState();
}

class _PatientSessionState extends State<_PatientSession> {
  AppState? _state;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final gate = widget.gate;
    await gate.storage.claimFor(widget.user.uid);
    final state = AppState(storage: gate.storage, reminders: gate.reminders, foods: gate.foods)
      ..onNutritionistMessage = _notifyMessage
      ..attachBackend(FirestorePatientBackend(widget.user.uid, gate.repo));
    if (mounted) setState(() => _state = state);
  }

  void _notifyMessage(ChatMessage message) {
    final inForeground = WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    if (inForeground) return;
    widget.gate.reminders.showMessage(
      'Nova mensagem da nutricionista',
      message.text ?? '📷 Foto',
    );
  }

  @override
  void dispose() {
    _state?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    if (state == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return AppStateScope(state: state, child: HomeShell(auth: widget.gate.auth));
  }
}

class _MessageScreen extends StatelessWidget {
  const _MessageScreen({
    required this.icon,
    required this.title,
    required this.message,
    required this.primary,
    required this.auth,
    this.secondary,
  });

  final IconData icon;
  final String title;
  final String message;
  final (String, VoidCallback) primary;
  final (String, VoidCallback)? secondary;
  final AuthService auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(onPressed: primary.$2, child: Text(primary.$1)),
                if (secondary != null) TextButton(onPressed: secondary!.$2, child: Text(secondary!.$1)),
                TextButton(onPressed: auth.signOut, child: const Text('Sair')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
