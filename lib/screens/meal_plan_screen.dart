import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/meal_plan.dart';
import '../state/app_state.dart';
import 'recipe_detail_screen.dart';
import 'settings_screen.dart';

/// Cardápio digital entregue na consulta, com opções alternativas.
class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = AppStateScope.of(context).mealPlan;
    final date = DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(plan.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu cardápio'),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Consulta de $date', style: Theme.of(context).textTheme.bodySmall),
          Text('Meta: ${plan.kcalTarget.round()} kcal/dia · água ${(plan.waterTargetMl / 1000).toStringAsFixed(1).replaceAll('.', ',')} L',
              style: Theme.of(context).textTheme.titleMedium),
          if (plan.generalNotes != null) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(plan.generalNotes!),
              ),
            ),
          ],
          const SizedBox(height: 8),
          for (final meal in plan.sortedMeals) _MealCard(meal: meal),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});

  final PlannedMeal meal;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text('${meal.type.label} · ${meal.time}'),
        subtitle: Text(meal.main.description),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OptionTile(option: meal.main),
          if (meal.alternatives.isNotEmpty) ...[
            const Divider(),
            Text('Opções alternativas', style: Theme.of(context).textTheme.labelLarge),
            for (final alt in meal.alternatives) _OptionTile(option: alt),
          ],
          if (meal.notes != null) ...[
            const SizedBox(height: 8),
            Text('Obs.: ${meal.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.option});

  final MealOption option;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ${option.description}'),
          Wrap(
            spacing: 8,
            children: [
              for (final id in option.recipeIds)
                if (state.recipeById(id) case final recipe?)
                  ActionChip(
                    avatar: const Icon(Icons.menu_book, size: 18),
                    label: Text('Como fazer: ${recipe.title}'),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: recipe),
                    )),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
