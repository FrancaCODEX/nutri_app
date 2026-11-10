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
  });

  final String id;
  final String name;
  final String category;
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
}
