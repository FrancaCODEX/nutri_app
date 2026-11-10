/// Alimento da Tabela Brasileira de Composição de Alimentos (TACO).
///
/// Todos os valores nutricionais são referentes a 100 g do alimento.
class Food {
  const Food({
    required this.id,
    required this.name,
    required this.category,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g = 0,
  });

  final String id;
  final String name;
  final String category;
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;

  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        kcalPer100g: (json['kcal'] as num).toDouble(),
        proteinPer100g: (json['protein'] as num).toDouble(),
        carbsPer100g: (json['carbs'] as num).toDouble(),
        fatPer100g: (json['fat'] as num).toDouble(),
        fiberPer100g: (json['fiber'] as num? ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'kcal': kcalPer100g,
        'protein': proteinPer100g,
        'carbs': carbsPer100g,
        'fat': fatPer100g,
        'fiber': fiberPer100g,
      };
}
