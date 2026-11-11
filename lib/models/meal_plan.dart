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

  MealOption copyWith({String? description, List<String>? recipeIds}) => MealOption(
        description: description ?? this.description,
        recipeIds: recipeIds ?? this.recipeIds,
      );

  factory MealOption.fromJson(Map<String, dynamic> json) => MealOption(
        description: json['description'] as String,
        recipeIds: List<String>.from(json['recipeIds'] as List? ?? const []),
      );

  Map<String, dynamic> toJson() => {'description': description, 'recipeIds': recipeIds};
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

  /// Horário no formato "HH:mm".
  final String time;
  final MealOption main;
  final List<MealOption> alternatives;
  final String? notes;

  /// Minutos desde a meia-noite (para ordenar e achar a próxima refeição).
  int get minutesOfDay {
    final parts = time.split(':');
    final h = int.tryParse(parts.first) ?? 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return h * 60 + m;
  }

  factory PlannedMeal.fromJson(Map<String, dynamic> json) => PlannedMeal(
        type: MealType.values.byName(json['type'] as String),
        time: json['time'] as String,
        main: MealOption.fromJson(json['main'] as Map<String, dynamic>),
        alternatives: (json['alternatives'] as List? ?? const [])
            .map((e) => MealOption.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'time': time,
        'main': main.toJson(),
        'alternatives': alternatives.map((a) => a.toJson()).toList(),
        'notes': notes,
      };
}

/// Cardápio entregue ao paciente na consulta.
class MealPlan {
  const MealPlan({
    required this.patientName,
    required this.nutritionistName,
    required this.createdAt,
    required this.kcalTarget,
    required this.meals,
    this.waterTargetMl = 2000,
    this.generalNotes,
  });

  final String patientName;
  final String nutritionistName;
  final DateTime createdAt;
  final double kcalTarget;
  final int waterTargetMl;
  final List<PlannedMeal> meals;
  final String? generalNotes;

  /// Refeições ordenadas por horário.
  List<PlannedMeal> get sortedMeals =>
      [...meals]..sort((a, b) => a.minutesOfDay.compareTo(b.minutesOfDay));

  /// Próxima refeição a partir de [now] (ou a primeira do dia seguinte).
  PlannedMeal? nextMeal(DateTime now) {
    final sorted = sortedMeals;
    if (sorted.isEmpty) return null;
    final minutes = now.hour * 60 + now.minute;
    return sorted.firstWhere((m) => m.minutesOfDay >= minutes, orElse: () => sorted.first);
  }

  MealPlan copyWith({
    String? patientName,
    String? nutritionistName,
    DateTime? createdAt,
    double? kcalTarget,
    int? waterTargetMl,
    List<PlannedMeal>? meals,
    String? generalNotes,
  }) =>
      MealPlan(
        patientName: patientName ?? this.patientName,
        nutritionistName: nutritionistName ?? this.nutritionistName,
        createdAt: createdAt ?? this.createdAt,
        kcalTarget: kcalTarget ?? this.kcalTarget,
        waterTargetMl: waterTargetMl ?? this.waterTargetMl,
        meals: meals ?? this.meals,
        generalNotes: generalNotes ?? this.generalNotes,
      );

  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan(
        patientName: json['patientName'] as String,
        nutritionistName: json['nutritionistName'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        kcalTarget: (json['kcalTarget'] as num).toDouble(),
        waterTargetMl: (json['waterTargetMl'] as num? ?? 2000).toInt(),
        meals: (json['meals'] as List)
            .map((e) => PlannedMeal.fromJson(e as Map<String, dynamic>))
            .toList(),
        generalNotes: json['generalNotes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'patientName': patientName,
        'nutritionistName': nutritionistName,
        'createdAt': createdAt.toIso8601String(),
        'kcalTarget': kcalTarget,
        'waterTargetMl': waterTargetMl,
        'meals': meals.map((m) => m.toJson()).toList(),
        'generalNotes': generalNotes,
      };
}
