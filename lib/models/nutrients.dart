/// Soma de calorias e macronutrientes.
class Nutrients {
  const Nutrients({
    this.kcal = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  static const zero = Nutrients();

  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  Nutrients operator +(Nutrients other) => Nutrients(
        kcal: kcal + other.kcal,
        protein: protein + other.protein,
        carbs: carbs + other.carbs,
        fat: fat + other.fat,
      );
}
