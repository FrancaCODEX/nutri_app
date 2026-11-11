import 'package:flutter/material.dart';

import '../../models/meal_plan.dart';
import '../../models/meal_type.dart';
import '../../state/app_state.dart';
import 'meal_editor_screen.dart';

/// Edição do cardápio entregue ao paciente.
class MealPlanEditorScreen extends StatefulWidget {
  const MealPlanEditorScreen({super.key, required this.initial});

  final MealPlan initial;

  @override
  State<MealPlanEditorScreen> createState() => _MealPlanEditorScreenState();
}

class _MealPlanEditorScreenState extends State<MealPlanEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _patient = TextEditingController(text: widget.initial.patientName);
  late final _nutri = TextEditingController(text: widget.initial.nutritionistName);
  late final _kcal = TextEditingController(text: widget.initial.kcalTarget.round().toString());
  late final _water = TextEditingController(text: widget.initial.waterTargetMl.toString());
  late final _notes = TextEditingController(text: widget.initial.generalNotes ?? '');
  late List<PlannedMeal> _meals = widget.initial.sortedMeals;
  bool _dirty = false;

  @override
  void dispose() {
    for (final c in [_patient, _nutri, _kcal, _water, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _editMeal([int? index]) async {
    final result = await Navigator.of(context).push<PlannedMeal>(
      MaterialPageRoute(
        builder: (_) => MealEditorScreen(initial: index == null ? null : _meals[index]),
      ),
    );
    if (result == null) return;
    setState(() {
      _dirty = true;
      final list = [..._meals];
      if (index == null) {
        list.add(result);
      } else {
        list[index] = result;
      }
      _meals = list..sort((a, b) => a.minutesOfDay.compareTo(b.minutesOfDay));
    });
  }

  void _removeMeal(int index) => setState(() {
        _dirty = true;
        _meals = [..._meals]..removeAt(index);
      });

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_meals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos uma refeição.')),
      );
      return;
    }
    final plan = widget.initial.copyWith(
      patientName: _patient.text.trim(),
      nutritionistName: _nutri.text.trim(),
      kcalTarget: double.parse(_kcal.text),
      waterTargetMl: int.parse(_water.text),
      generalNotes: _notes.text.trim(),
      meals: _meals,
      createdAt: DateTime.now(),
    );
    await AppStateScope.read(context).updateMealPlan(plan);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cardápio salvo.')));
    Navigator.of(context).pop();
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar alterações?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Continuar editando')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Descartar')),
        ],
      ),
    );
    return discard ?? false;
  }

  String? _requiredNumber(String? v) {
    final n = int.tryParse(v ?? '');
    return n == null || n <= 0 ? 'Informe um número válido' : null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar cardápio'),
          actions: [TextButton(onPressed: _save, child: const Text('Salvar'))],
        ),
        body: Form(
          key: _formKey,
          onChanged: () => _dirty = true,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _patient,
                decoration: const InputDecoration(labelText: 'Paciente'),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nutri,
                decoration: const InputDecoration(labelText: 'Nutricionista'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _kcal,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Meta (kcal/dia)'),
                      validator: _requiredNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _water,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Água (ml/dia)'),
                      validator: _requiredNumber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Orientações gerais'),
              ),
              const SizedBox(height: 20),
              Text('Refeições', style: Theme.of(context).textTheme.titleMedium),
              for (var i = 0; i < _meals.length; i++)
                Card(
                  child: ListTile(
                    title: Text('${_meals[i].time} · ${_meals[i].type.label}'),
                    subtitle: Text(
                      '${_meals[i].main.description}'
                      '${_meals[i].alternatives.isEmpty ? '' : '\n+ ${_meals[i].alternatives.length} alternativa(s)'}',
                    ),
                    onTap: () => _editMeal(i),
                    trailing: IconButton(
                      tooltip: 'Remover refeição',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _removeMeal(i),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _editMeal(),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar refeição'),
              ),
              const SizedBox(height: 8),
              Text(
                'Tipos disponíveis: ${MealType.values.map((m) => m.label).join(', ')}.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
