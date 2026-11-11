import 'package:flutter/material.dart';

import '../../models/recipe.dart';
import '../../services/photo_service.dart';
import '../../state/app_state.dart';
import '../../widgets/app_image.dart';

/// Criação e edição de receitas pela nutricionista.
class RecipeEditorScreen extends StatefulWidget {
  const RecipeEditorScreen({super.key, this.initial});

  final Recipe? initial;

  @override
  State<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends State<RecipeEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _photos = PhotoService();
  late final _title = TextEditingController(text: widget.initial?.title ?? '');
  late final _kcal = TextEditingController(text: widget.initial?.kcalPerServing.round().toString() ?? '');
  late final _servings = TextEditingController(text: widget.initial?.servings.toString() ?? '1');
  late final _minutes = TextEditingController(text: widget.initial?.prepMinutes.toString() ?? '');
  late final _ingredients = TextEditingController(text: widget.initial?.ingredients.join('\n') ?? '');
  late final _steps = TextEditingController(text: widget.initial?.steps.join('\n') ?? '');
  late final _tags = TextEditingController(text: widget.initial?.tags.join(', ') ?? '');
  late RecipeCategory _category = widget.initial?.category ?? RecipeCategory.savory;
  late String? _image = widget.initial?.imageUrl;

  @override
  void dispose() {
    for (final c in [_title, _kcal, _servings, _minutes, _ingredients, _steps, _tags]) {
      c.dispose();
    }
    super.dispose();
  }

  static List<String> _lines(String text) =>
      text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

  String? _required(String? v) => (v ?? '').trim().isEmpty ? 'Obrigatório' : null;

  String? _positiveInt(String? v) {
    final n = int.tryParse(v ?? '');
    return n == null || n <= 0 ? 'Número válido' : null;
  }

  Future<void> _pickPhoto(bool fromCamera) async {
    try {
      final path = await _photos.pick(fromCamera: fromCamera, folder: 'recipe_photos');
      if (path != null) setState(() => _image = path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir a câmera/galeria.')),
      );
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final state = AppStateScope.read(context);
    state.saveRecipe(Recipe(
      id: widget.initial?.id ?? state.newRecipeId(),
      title: _title.text.trim(),
      category: _category,
      ingredients: _lines(_ingredients.text),
      steps: _lines(_steps.text),
      kcalPerServing: double.parse(_kcal.text),
      servings: int.parse(_servings.text),
      prepMinutes: int.parse(_minutes.text),
      imageUrl: _image,
      tags: _tags.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
      isCustom: true,
    ));
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir receita?'),
        content: const Text('Ela deixa de aparecer para o paciente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    AppStateScope.read(context).deleteRecipe(widget.initial!.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'Nova receita' : 'Editar receita'),
        actions: [
          if (widget.initial != null)
            IconButton(tooltip: 'Excluir', onPressed: _delete, icon: const Icon(Icons.delete_outline)),
          TextButton(onPressed: _save, child: const Text('Salvar')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 180,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: _image == null
                    ? const Center(child: Icon(Icons.photo_outlined, size: 48))
                    : AppImage(_image!, width: double.infinity, height: 180),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => _pickPhoto(true),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Câmera'),
                ),
                TextButton.icon(
                  onPressed: () => _pickPhoto(false),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galeria'),
                ),
                if (_image != null)
                  TextButton(onPressed: () => setState(() => _image = null), child: const Text('Remover')),
              ],
            ),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Nome da receita'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RecipeCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: [
                for (final c in RecipeCategory.values) DropdownMenuItem(value: c, child: Text(c.label)),
              ],
              onChanged: (c) => setState(() => _category = c ?? _category),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _kcal,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'kcal/porção'),
                    validator: _positiveInt,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _servings,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Porções'),
                    validator: _positiveInt,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _minutes,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Minutos'),
                    validator: _positiveInt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ingredients,
              minLines: 3,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Ingredientes',
                helperText: 'Um por linha',
                alignLabelWithHint: true,
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _steps,
              minLines: 3,
              maxLines: 12,
              decoration: const InputDecoration(
                labelText: 'Modo de preparo',
                helperText: 'Um passo por linha',
                alignLabelWithHint: true,
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tags,
              decoration: const InputDecoration(
                labelText: 'Tags (opcional)',
                helperText: 'Separadas por vírgula. Ex.: café da manhã, sem glúten',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
