import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_app/models/diary_entry.dart';
import 'package:nutri_app/models/food.dart';
import 'package:nutri_app/models/meal_type.dart';
import 'package:nutri_app/services/nutrition_calculator.dart';

const _rice = Food(
  id: 'rice', name: 'Arroz', category: 'Cereais',
  kcalPer100g: 128, proteinPer100g: 2.5, carbsPer100g: 28.1, fatPer100g: 0.2,
);

void main() {
  test('calcula porção proporcional aos valores por 100 g', () {
    final n = NutritionCalculator.forPortion(_rice, 150);
    expect(n.kcal, closeTo(192, 0.001));
    expect(n.carbs, closeTo(42.15, 0.001));
  });

  test('porção zero ou negativa resulta em zero', () {
    expect(NutritionCalculator.forPortion(_rice, 0).kcal, 0);
    expect(NutritionCalculator.forPortion(_rice, -10).kcal, 0);
  });

  test('soma o total e agrupa por refeição', () {
    final day = DateTime(2026, 11, 10);
    final entries = [
      DiaryEntry(id: '1', food: _rice, grams: 100, meal: MealType.lunch, date: day),
      DiaryEntry(id: '2', food: _rice, grams: 50, meal: MealType.dinner, date: day),
    ];
    expect(NutritionCalculator.total(entries).kcal, closeTo(192, 0.001));
    final byMeal = NutritionCalculator.byMeal(entries);
    expect(byMeal[MealType.lunch]!.kcal, closeTo(128, 0.001));
    expect(byMeal[MealType.dinner]!.kcal, closeTo(64, 0.001));
  });
}
