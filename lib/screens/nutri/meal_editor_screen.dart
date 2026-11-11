import 'package:flutter/material.dart';

import '../../models/meal_plan.dart';
import '../../models/meal_type.dart';
import '../../models/recipe.dart';

/// Edita uma refeição do cardápio: horário, opção principal e alternativas.
class MealEditorScreen extends StatefulWidget {
  const MealEditorScreen({super.key, this.initial, required this.recipes});

  final PlannedMeal? initial;
  final List<Recipe> recipes;

  Recipe? recipeById(String id) {
    for (final r in recipes) {
      if (r.id == id) return r;
    }
    return null;
  }

  @override
  State<MealEditorScreen> createState() => _MealEditorScreenState();
}

class _OptionDraft {
  _OptionDraft(MealOption? option)
      : controller = TextEditingController(text: option?.description ?? ''),
        recipeIds = [...?option?.recipeIds];

  final TextEditingController controller;
  final List<String> recipeIds;

  MealOption toOption() => MealOption(description: controller.text.trim(), recipeIds: recipeIds);
}

class _MealEditorScreenState extends State<MealEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late MealType _type = widget.initial?.type ?? MealType.breakfast;
  late TimeOfDay _time = _parseTime(widget.initial?.time ?? '07:00');
  late final _main = _OptionDraft(widget.initial?.main);
  late final List<_OptionDraft> _alternatives =
      [for (final a in widget.initial?.alternatives ?? const <MealOption>[]) _OptionDraft(a)];
  late final _notes = TextEditingController(text: widget.initial?.notes ?? '');

  static TimeOfDay _parseTime(String hhmm) {
    final p = hhmm.split(':');
    return TimeOfDay(hour: int.tryParse(p[0]) ?? 7, minute: p.length > 1 ? int.tryParse(p[1]) ?? 0 : 0);
  }

  String get _timeText =>
      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _main.controller.dispose();
    for (final a in _alternatives) {
      a.controller.dispose();
    }
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _pickRecipes(_OptionDraft draft) async {
    final recipes = widget.recipes;
    if (recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre receitas primeiro na aba Receitas.')),
      );
      return;
    }
    final selected = {...draft.recipeIds};
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Receitas ligadas a esta opção'),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final r in recipes)
                      CheckboxListTile(
                        value: selected.contains(r.id),
                        title: Text(r.title),
                        onChanged: (v) => setSheet(() => v == true ? selected.add(r.id) : selected.remove(r.id)),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, selected),
                  child: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null) {
      setState(() => draft.recipeIds
        ..clear()
        ..addAll(result));
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final alternatives = [
      for (final a in _alternatives)
        if (a.controller.text.trim().isNotEmpty) a.toOption(),
    ];
    Navigator.of(context).pop(PlannedMeal(
      type: _type,
      time: _timeText,
      main: _main.toOption(),
      alternatives: alternatives,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    ));
  }

  Widget _optionEditor(_OptionDraft draft, String label, {VoidCallback? onRemove}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: draft.controller,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: label),
                    validator: onRemove == null
                        ? (v) => (v ?? '').trim().isEmpty ? 'Obrigatório' : null
                        : null,
                  ),
                ),
                if (onRemove != null)
                  IconButton(tooltip: 'Remover', icon: const Icon(Icons.close), onPressed: onRemove),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final id in draft.recipeIds)
                  if (widget.recipeById(id) case final r?)
                    Chip(
                      label: Text(r.title),
                      onDeleted: () => setState(() => draft.recipeIds.remove(id)),
                    ),
                ActionChip(
                  avatar: const Icon(Icons.menu_book, size: 18),
                  label: const Text('Ligar receitas'),
                  onPressed: () => _pickRecipes(draft),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'Nova refeição' : 'Editar refeição'),
        actions: [TextButton(onPressed: _save, child: const Text('OK'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<MealType>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Refeição'),
                    items: [
                      for (final m in MealType.values) DropdownMenuItem(value: m, child: Text(m.label)),
                    ],
                    onChanged: (m) => setState(() => _type = m ?? _type),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.schedule),
                  label: Text(_timeText),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _optionEditor(_main, 'Opção principal'),
            const SizedBox(height: 8),
            Text('Opções alternativas', style: Theme.of(context).textTheme.titleSmall),
            for (var i = 0; i < _alternatives.length; i++)
              _optionEditor(
                _alternatives[i],
                'Alternativa ${i + 1}',
                onRemove: () => setState(() => _alternatives.removeAt(i).controller.dispose()),
              ),
            TextButton.icon(
              onPressed: () => setState(() => _alternatives.add(_OptionDraft(null))),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar alternativa'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Observação (opcional)'),
            ),
          ],
        ),
      ),
    );
  }
}
