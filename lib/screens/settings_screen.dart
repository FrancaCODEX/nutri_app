import 'package:flutter/material.dart';

import '../state/app_state.dart';
import 'nutri/nutri_area_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const appVersion = '0.3.0';

  Future<void> _toggleReminders(BuildContext context, bool value) async {
    final ok = await AppStateScope.read(context).setRemindersEnabled(value);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Permita as notificações do Nutri App nas configurações do celular.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Lembretes de refeição'),
            subtitle: const Text('Aviso no horário de cada refeição do cardápio'),
            value: state.remindersEnabled,
            onChanged: (v) => _toggleReminders(context, v),
          ),
          if (state.remindersEnabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
              child: Text(
                [for (final m in state.mealPlan.sortedMeals) '${m.time} ${m.type.label}'].join(' · '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Área da nutricionista'),
            subtitle: const Text('Editar cardápio e criar receitas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NutriAreaScreen()),
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
