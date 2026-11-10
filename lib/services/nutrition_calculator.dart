import '../models/diary_entry.dart';
import '../models/food.dart';
import '../models/meal_type.dart';
import '../models/nutrients.dart';

/// Cálculos nutricionais a partir dos valores por 100 g da TACO.
class NutritionCalculator {
  const NutritionCalculator._();

  static Nutrients forPortion(Food food, double grams) {
    if (grams <= 0) return Nutrients.zero;
    final factor = grams / 100;
    return Nutrients(
      kcal: food.kcalPer100g * factor,
      protein: food.proteinPer100g * factor,
      carbs: food.carbsPer100g * factor,
      fat: food.fatPer100g * factor,
    );
  }

  static Nutrients total(Iterable<DiaryEntry> entries) => entries.fold(
        Nutrients.zero,
        (sum, e) => sum + forPortion(e.food, e.grams),
      );

  static Map<MealType, Nutrients> byMeal(Iterable<DiaryEntry> entries) {
    final result = <MealType, Nutrients>{};
    for (final e in entries) {
      result[e.meal] =
          (result[e.meal] ?? Nutrients.zero) + forPortion(e.food, e.grams);
    }
    return result;
  }
}
