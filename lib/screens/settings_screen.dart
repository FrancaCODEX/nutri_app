import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../state/app_state.dart';
import 'auth/change_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.auth});

  /// Presente quando há login (paciente conectado à nuvem).
  final AuthService? auth;

  static const appVersion = '0.4.0';

  Future<void> _toggleReminders(BuildContext context, bool value) async {
    final ok = await AppStateScope.read(context).setRemindersEnabled(value);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Permita as notificações do Nutri App nas configurações do celular.'),
      ));
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Seus dados continuam salvos na nuvem.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sair')),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
    await auth!.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final user = auth?.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          if (user != null) ...[
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: Text(state.mealPlan.patientName.isEmpty ? 'Minha conta' : state.mealPlan.patientName),
              subtitle: Text(user.email ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.password),
              title: const Text('Alterar senha'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ChangePasswordScreen(auth: auth!)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () => _signOut(context),
            ),
            const Divider(),
          ],
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Lembretes de refeição'),
            subtitle: const Text('Aviso no horário de cada refeição do cardápio'),
            value: state.remindersEnabled,
            onChanged: (v) => _toggleReminders(context, v),
          ),
          if (state.remindersEnabled && state.mealPlan.meals.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
              child: Text(
                [for (final m in state.mealPlan.sortedMeals) '${m.time} ${m.type.label}'].join(' · '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dataset_outlined),
            title: const Text('Base de alimentos'),
            subtitle: Text('Tabela TACO (NEPA/UNICAMP) · ${state.foods.length} alimentos'),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Versão'),
            subtitle: Text('$appVersion (teste)'),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Os valores nutricionais são estimativas e não substituem a '
              'orientação da sua nutricionista.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
