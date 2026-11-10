import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/meal_type.dart';
import '../services/nutrition_calculator.dart';
import '../state/app_state.dart';
import 'add_food_screen.dart';

/// Diário alimentar: o que o paciente comeu no dia e o total de calorias.
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DateTime _day = DateUtils.dateOnly(DateTime.now());

  void _shiftDay(int days) =>
      setState(() => _day = _day.add(Duration(days: days)));

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final entries = state.entriesFor(_day);
    final total = NutritionCalculator.total(entries);
    final target = state.mealPlan.kcalTarget;
    final progress = (total.kcal / target).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário alimentar'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () => _shiftDay(-1), icon: const Icon(Icons.chevron_left)),
              Text(DateFormat("EEE, d 'de' MMM", 'pt_BR').format(_day)),
              IconButton(onPressed: () => _shiftDay(1), icon: const Icon(Icons.chevron_right)),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${total.kcal.round()} / ${target.round()} kcal',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress, minHeight: 8),
                  const SizedBox(height: 8),
                  Text('Proteínas ${total.protein.toStringAsFixed(1)} g · '
                      'Carboidratos ${total.carbs.toStringAsFixed(1)} g · '
                      'Gorduras ${total.fat.toStringAsFixed(1)} g'),
                ],
              ),
            ),
          ),
          for (final meal in MealType.values) ...[
            if (entries.any((e) => e.meal == meal)) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 4),
                child: Text(meal.label, style: Theme.of(context).textTheme.titleMedium),
              ),
              for (final e in entries.where((e) => e.meal == meal))
                Dismissible(
                  key: ValueKey(e.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.red.shade100,
                    child: const Icon(Icons.delete),
                  ),
                  onDismissed: (_) {
                    state.removeDiaryEntry(e.id);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text('${e.food.name} removido'),
                        action: SnackBarAction(
                          label: 'Desfazer',
                          onPressed: () => state.restoreDiaryEntry(e),
                        ),
                      ));
                  },
                  child: ListTile(
                    title: Text(e.food.name),
                    subtitle: Text(e.portionLabel == null
                        ? '${e.grams.round()} g'
                        : '${e.portionLabel} · ${e.grams.round()} g'),
                    trailing: Text(
                        '${NutritionCalculator.forPortion(e.food, e.grams).kcal.round()} kcal'),
                  ),
                ),
            ],
          ],
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: Text('Nada registrado neste dia ainda.')),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AddFoodScreen(day: _day),
        )),
      ),
    );
  }
}
