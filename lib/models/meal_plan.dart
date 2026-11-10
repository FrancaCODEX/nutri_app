import 'meal_type.dart';

/// Uma opção de refeição dentro do cardápio (ex.: "2 ovos + 1 pão integral").
class MealOption {
  const MealOption({
    required this.description,
    this.recipeIds = const [],
  });

  final String description;

  /// Receitas que ajudam o paciente a preparar esta opção.
  final List<String> recipeIds;
}

/// Refeição do cardápio: a opção principal e as alternativas equivalentes.
class PlannedMeal {
  const PlannedMeal({
    required this.type,
    required this.time,
    required this.main,
    this.alternatives = const [],
    this.notes,
  });

  final MealType type;
  final String time;
  final MealOption main;
  final List<MealOption> alternatives;
  final String? notes;
}

/// Cardápio entregue ao paciente na consulta.
class MealPlan {
  const MealPlan({
    required this.patientName,
    required this.nutritionistName,
    required this.createdAt,
    required this.kcalTarget,
    required this.meals,
    this.generalNotes,
  });

  final String patientName;
  final String nutritionistName;
  final DateTime createdAt;
  final double kcalTarget;
  final List<PlannedMeal> meals;
  final String? generalNotes;
}
