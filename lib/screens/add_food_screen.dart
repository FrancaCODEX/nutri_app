import 'package:flutter/material.dart';

import '../models/food.dart';
import '../models/meal_type.dart';
import '../services/nutrition_calculator.dart';
import '../state/app_state.dart';

/// Busca de alimento na TACO e registro da porção consumida.
class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key, required this.day});

  final DateTime day;

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final foods = AppStateScope.of(context).searchFoods(_query);
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar alimento')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Ex.: arroz, frango, banana',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foods.length,
              itemBuilder: (context, i) {
                final f = foods[i];
                return ListTile(
                  title: Text(f.name),
                  subtitle: Text('${f.category} · ${f.kcalPer100g.round()} kcal / 100 g'),
                  onTap: () => _openPortionSheet(f),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPortionSheet(Food food) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PortionSheet(food: food, day: widget.day),
    );
    if (saved == true && mounted) Navigator.of(context).pop();
  }
}

class _PortionSheet extends StatefulWidget {
  const _PortionSheet({required this.food, required this.day});

  final Food food;
  final DateTime day;

  @override
  State<_PortionSheet> createState() => _PortionSheetState();
}

class _PortionSheetState extends State<_PortionSheet> {
  final _gramsController = TextEditingController(text: '100');
  MealType _meal = MealType.lunch;

  double get _grams =>
      double.tryParse(_gramsController.text.replaceAll(',', '.')) ?? 0;

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = NutritionCalculator.forPortion(widget.food, _grams);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.food.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _gramsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Quantidade (g)',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<MealType>(
            initialValue: _meal,
            decoration: const InputDecoration(labelText: 'Refeição', border: OutlineInputBorder()),
            items: [
              for (final m in MealType.values)
                DropdownMenuItem(value: m, child: Text(m.label)),
            ],
            onChanged: (m) => setState(() => _meal = m ?? _meal),
          ),
          const SizedBox(height: 12),
          Text(
            '${n.kcal.round()} kcal · P ${n.protein.toStringAsFixed(1)} g · '
            'C ${n.carbs.toStringAsFixed(1)} g · G ${n.fat.toStringAsFixed(1)} g',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _grams <= 0
                ? null
                : () {
                    AppStateScope.of(context).addDiaryEntry(
                      food: widget.food,
                      grams: _grams,
                      meal: _meal,
                      date: widget.day,
                    );
                    Navigator.of(context).pop(true);
                  },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
