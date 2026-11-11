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
    this.isCustom = false,
  });

  final String id;
  final String title;
  final RecipeCategory category;
  final List<String> ingredients;
  final List<String> steps;
  final double kcalPerServing;
  final int servings;
  final int prepMinutes;

  /// URL (http) ou caminho local da foto.
  final String? imageUrl;
  final List<String> tags;

  /// `true` para receitas criadas no app pela nutricionista (editáveis).
  final bool isCustom;

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] as String,
        title: json['title'] as String,
        category: RecipeCategory.values.byName(json['category'] as String),
        ingredients: List<String>.from(json['ingredients'] as List),
        steps: List<String>.from(json['steps'] as List),
        kcalPerServing: (json['kcalPerServing'] as num).toDouble(),
        servings: (json['servings'] as num).toInt(),
        prepMinutes: (json['prepMinutes'] as num).toInt(),
        imageUrl: json['imageUrl'] as String?,
        tags: List<String>.from(json['tags'] as List? ?? const []),
        isCustom: json['isCustom'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category.name,
        'ingredients': ingredients,
        'steps': steps,
        'kcalPerServing': kcalPerServing,
        'servings': servings,
        'prepMinutes': prepMinutes,
        'imageUrl': imageUrl,
        'tags': tags,
        'isCustom': isCustom,
      };
}
