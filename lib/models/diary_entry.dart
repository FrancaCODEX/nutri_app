import 'food.dart';
import 'meal_type.dart';

/// Registro de um alimento consumido pelo paciente.
class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.food,
    required this.grams,
    required this.meal,
    required this.date,
  });

  final String id;
  final Food food;
  final double grams;
  final MealType meal;
  final DateTime date;
}
