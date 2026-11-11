import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import 'meal_plan_editor_screen.dart';
import 'recipe_editor_screen.dart';

/// Área da nutricionista: editar o cardápio do paciente e as receitas.
///
/// Nesta versão as alterações ficam no aparelho. Com o Firebase (próxima fase)
/// esta área passa a exigir login de nutricionista e a salvar na nuvem.
class NutriAreaScreen extends StatelessWidget {
  const NutriAreaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final custom = state.recipes.where((r) => r.isCustom).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Área da nutricionista')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.edit_calendar_outlined),
            title: const Text('Editar cardápio'),
            subtitle: Text('${state.mealPlan.patientName} · ${state.mealPlan.meals.length} refeições'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MealPlanEditorScreen(initial: state.mealPlan)),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('Minhas receitas', style: Theme.of(context).textTheme.titleMedium),
          ),
          if (custom.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nenhuma receita criada ainda. As receitas criadas aqui '
                  'aparecem para o paciente na aba Receitas.'),
            ),
          for (final r in custom)
            ListTile(
              title: Text(r.title),
              subtitle: Text('${r.category.label} · ${r.kcalPerServing.round()} kcal/porção'),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => RecipeEditorScreen(initial: r)),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nova receita'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RecipeEditorScreen()),
        ),
      ),
    );
  }
}
