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
    this.portionLabel,
  });

  final String id;
  final Food food;
  final double grams;
  final MealType meal;
  final DateTime date;

  /// Descrição da porção em medida caseira (ex.: "2 colher de sopa").
  final String? portionLabel;

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
        id: json['id'] as String,
        food: Food.fromJson(json['food'] as Map<String, dynamic>),
        grams: (json['grams'] as num).toDouble(),
        meal: MealType.values.byName(json['meal'] as String),
        date: DateTime.parse(json['date'] as String),
        portionLabel: json['portionLabel'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'food': food.toJson(),
        'grams': grams,
        'meal': meal.name,
        'date': date.toIso8601String(),
        'portionLabel': portionLabel,
      };
}
