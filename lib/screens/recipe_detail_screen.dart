import 'package:flutter/material.dart';

import '../models/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (recipe.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(recipe.imageUrl!, height: 200, fit: BoxFit.cover),
            ),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(recipe.category.label)),
              Chip(label: Text('${recipe.kcalPerServing.round()} kcal/porção')),
              Chip(label: Text('${recipe.prepMinutes} min')),
              Chip(label: Text('${recipe.servings} porção(ões)')),
            ],
          ),
          const SizedBox(height: 16),
          Text('Ingredientes', style: text.titleMedium),
          for (final i in recipe.ingredients) Text('• $i'),
          const SizedBox(height: 16),
          Text('Modo de preparo', style: text.titleMedium),
          for (var n = 0; n < recipe.steps.length; n++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('${n + 1}. ${recipe.steps[n]}'),
            ),
        ],
      ),
    );
  }
}
