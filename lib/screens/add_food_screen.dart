import 'package:flutter/material.dart';

import '../models/food.dart';
import '../models/household_measure.dart';
import '../models/meal_type.dart';
import '../services/household_measures.dart';
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
    final state = AppStateScope.of(context);
    final searching = _query.trim().isNotEmpty;
    final recents = searching ? const <Food>[] : state.recentFoods();
    final foods = searching ? state.searchFoods(_query) : const <Food>[];

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
                hintText: 'Ex.: arroz, frango grelhado, banana',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (!searching && recents.isNotEmpty) ...[
                  const _SectionTitle('Usados recentemente'),
                  for (final f in recents) _FoodTile(food: f, onTap: () => _openPortionSheet(f)),
                ],
                if (!searching && recents.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Digite o nome do alimento para buscar entre os '
                      '${state.foods.length} itens da Tabela TACO.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (searching && foods.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Nenhum alimento encontrado. Tente outra palavra.',
                        textAlign: TextAlign.center),
                  ),
                for (final f in foods) _FoodTile(food: f, onTap: () => _openPortionSheet(f)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPortionSheet(Food food) async {
    FocusScope.of(context).unfocus();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PortionSheet(food: food, day: widget.day),
    );
    if (saved == true && mounted) Navigator.of(context).pop();
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      );
}

class _FoodTile extends StatelessWidget {
  const _FoodTile({required this.food, required this.onTap});

  final Food food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(food.name),
        subtitle: Text('${food.category} · ${food.kcalPer100g.round()} kcal / 100 g'),
        trailing: const Icon(Icons.add_circle_outline),
        onTap: onTap,
      );
}

class _PortionSheet extends StatefulWidget {
  const _PortionSheet({required this.food, required this.day});

  final Food food;
  final DateTime day;

  @override
  State<_PortionSheet> createState() => _PortionSheetState();
}

class _PortionSheetState extends State<_PortionSheet> {
  late final List<HouseholdMeasure> _measures = HouseholdMeasures.forFood(widget.food);
  late HouseholdMeasure _measure = _measures.first;
  late final _amountController =
      TextEditingController(text: _measure.isGrams ? '100' : '1');
  MealType _meal = _guessMeal();

  static MealType _guessMeal() {
    final h = DateTime.now().hour;
    if (h < 10) return MealType.breakfast;
    if (h < 12) return MealType.morningSnack;
    if (h < 15) return MealType.lunch;
    if (h < 18) return MealType.afternoonSnack;
    if (h < 21) return MealType.dinner;
    return MealType.supper;
  }

  double get _amount =>
      double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

  double get _grams => _amount * _measure.grams;

  String _formatAmount(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString().replaceAll('.', ',');

  String? get _portionLabel => _measure.isGrams
      ? null
      : '${_formatAmount(_amount)} ${_measure.label}';

  void _selectMeasure(HouseholdMeasure m) {
    setState(() {
      _measure = m;
      _amountController.text = m.isGrams ? '100' : '1';
    });
  }

  void _step(double delta) {
    final next = (_amount + delta).clamp(0, 9999).toDouble();
    setState(() => _amountController.text = _formatAmount(next));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = NutritionCalculator.forPortion(widget.food, _grams);
    final stepSize = _measure.isGrams ? 10.0 : 0.5;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.food.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final m in _measures)
                ChoiceChip(
                  label: Text(m.isGrams ? 'gramas' : '${m.label} (${m.grams.round()} g)'),
                  selected: m == _measure,
                  onSelected: (_) => _selectMeasure(m),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton.filledTonal(onPressed: () => _step(-stepSize), icon: const Icon(Icons.remove)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: _measure.isGrams ? 'Quantidade (g)' : 'Quantidade (${_measure.label})',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(onPressed: () => _step(stepSize), icon: const Icon(Icons.add)),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<MealType>(
            initialValue: _meal,
            decoration: const InputDecoration(labelText: 'Refeição'),
            items: [
              for (final m in MealType.values) DropdownMenuItem(value: m, child: Text(m.label)),
            ],
            onChanged: (m) => setState(() => _meal = m ?? _meal),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text('${n.kcal.round()} kcal',
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(
                    '${_grams.round()} g · P ${n.protein.toStringAsFixed(1)} g · '
                    'C ${n.carbs.toStringAsFixed(1)} g · G ${n.fat.toStringAsFixed(1)} g',
                  ),
                ],
              ),
            ),
          ),
          if (!_measure.isGrams)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Peso da medida caseira é aproximado.',
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _grams <= 0
                ? null
                : () {
                    AppStateScope.read(context).addDiaryEntry(
                      food: widget.food,
                      grams: _grams,
                      meal: _meal,
                      date: widget.day,
                      portionLabel: _portionLabel,
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
