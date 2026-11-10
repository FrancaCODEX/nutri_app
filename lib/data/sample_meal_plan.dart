import '../models/meal_plan.dart';
import '../models/meal_type.dart';

/// Cardápio de exemplo, como se tivesse sido entregue na consulta.
final MealPlan sampleMealPlan = MealPlan(
  patientName: 'Paciente Exemplo',
  nutritionistName: 'Nutricionista',
  createdAt: DateTime(2026, 11, 10),
  kcalTarget: 1800,
  generalNotes: 'Beber pelo menos 2 L de água por dia. '
      'As opções de cada refeição são equivalentes: escolha a que preferir.',
  meals: const [
    PlannedMeal(
      type: MealType.breakfast,
      time: '07:00',
      main: MealOption(description: '2 ovos mexidos + 1 fatia de pão integral + 1 fruta'),
      alternatives: [
        MealOption(description: 'Panqueca de banana com aveia', recipeIds: ['r_panqueca_banana']),
        MealOption(description: '1 iogurte natural + 2 colheres de aveia + 1/2 maçã', recipeIds: ['r_iogurte_frutas']),
      ],
    ),
    PlannedMeal(
      type: MealType.lunch,
      time: '12:30',
      main: MealOption(description: '4 col. de arroz + 1 concha de feijão + 120 g de frango + salada à vontade'),
      alternatives: [
        MealOption(description: 'Frango grelhado com batata-doce assada + salada', recipeIds: ['r_frango_batata_doce']),
        MealOption(description: '120 g de patinho + 4 col. de arroz integral + legumes'),
      ],
      notes: 'Comece pela salada.',
    ),
    PlannedMeal(
      type: MealType.afternoonSnack,
      time: '16:00',
      main: MealOption(description: '1 iogurte natural + 1 fruta'),
      alternatives: [
        MealOption(description: '1 fatia de pão integral + 1 fatia de queijo minas'),
      ],
    ),
    PlannedMeal(
      type: MealType.dinner,
      time: '19:30',
      main: MealOption(description: 'Omelete de legumes + salada', recipeIds: ['r_omelete_legumes']),
      alternatives: [
        MealOption(description: 'Mesmo esquema do almoço, em porção menor'),
      ],
    ),
  ],
);
