import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../state/app_state.dart';
import 'recipe_detail_screen.dart';

/// Lista de receitas com filtro por categoria e busca.
class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  RecipeCategory? _category;
  bool _onlyFavorites = false;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final all = state.recipes;
    final q = _query.toLowerCase();
    final recipes = all.where((r) {
      final matchesCategory = _category == null || r.category == _category;
      final matchesQuery = q.isEmpty ||
          r.title.toLowerCase().contains(q) ||
          r.tags.any((t) => t.toLowerCase().contains(q));
      final matchesFavorite = !_onlyFavorites || state.isFavorite(r.id);
      return matchesCategory && matchesQuery && matchesFavorite;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Receitas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar receita',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(_onlyFavorites ? Icons.favorite : Icons.favorite_border, size: 18),
                    label: const Text('Favoritas'),
                    selected: _onlyFavorites,
                    showCheckmark: false,
                    onSelected: (v) => setState(() => _onlyFavorites = v),
                  ),
                ),
                _chip('Todas', null),
                for (final c in RecipeCategory.values) _chip(c.label, c),
              ],
            ),
          ),
          Expanded(
            child: recipes.isEmpty
                ? Center(
                    child: Text(_onlyFavorites
                        ? 'Toque no coração de uma receita para salvá-la aqui.'
                        : 'Nenhuma receita encontrada'),
                  )
                : ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, i) {
                      final r = recipes[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text(r.category.label[0])),
                        title: Text(r.title),
                        subtitle: Text(
                            '${r.kcalPerServing.round()} kcal/porção · ${r.prepMinutes} min'),
                        trailing: IconButton(
                          tooltip: 'Favoritar',
                          icon: Icon(state.isFavorite(r.id) ? Icons.favorite : Icons.favorite_border,
                              color: state.isFavorite(r.id) ? Colors.redAccent : null),
                          onPressed: () => state.toggleFavorite(r.id),
                        ),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => RecipeDetailScreen(recipe: r),
                        )),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, RecipeCategory? value) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: _category == value,
          onSelected: (_) => setState(() => _category = value),
        ),
      );
}
