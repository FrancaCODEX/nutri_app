enum RecipeCategory {
  sweet('Doce'),
  savory('Salgado'),
  drink('Bebida'),
  snack('Lanche');

  const RecipeCategory(this.label);

  final String label;
}

/// Receita publicada pela nutricionista.
class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.kcalPerServing,
    required this.servings,
    required this.prepMinutes,
    this.imageUrl,
    this.tags = const [],
  });

  final String id;
  final String title;
  final RecipeCategory category;
  final List<String> ingredients;
  final List<String> steps;
  final double kcalPerServing;
  final int servings;
  final int prepMinutes;
  final String? imageUrl;
  final List<String> tags;
}
