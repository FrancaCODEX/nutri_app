import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_app/data/local_storage.dart';
import 'package:nutri_app/data/sample_meal_plan.dart';
import 'package:nutri_app/models/meal_plan.dart';
import 'package:nutri_app/models/meal_type.dart';
import 'package:nutri_app/models/recipe.dart';
import 'package:nutri_app/state/app_state.dart';

import 'helpers/fakes.dart';

Future<AppState> reopen() async =>
    AppState(storage: await LocalStorage.open(), reminders: FakeReminders(), foods: const [rice]);

void main() {
  test('cardápio: JSON ida e volta preserva tudo', () {
    final json = sampleMealPlan.toJson();
    final back = MealPlan.fromJson(json);
    expect(back.toJson(), json);
    expect(back.meals.first.alternatives, isNotEmpty);
  });

  test('próxima refeição respeita horário e volta para a primeira do dia', () {
    final plan = MealPlan(
      patientName: 'P', nutritionistName: 'N', createdAt: DateTime(2026, 11, 11), kcalTarget: 1800,
      meals: const [
        PlannedMeal(type: MealType.dinner, time: '19:30', main: MealOption(description: 'jantar')),
        PlannedMeal(type: MealType.breakfast, time: '07:00', main: MealOption(description: 'café')),
        PlannedMeal(type: MealType.lunch, time: '12:30', main: MealOption(description: 'almoço')),
      ],
    );
    expect(plan.sortedMeals.map((m) => m.time), ['07:00', '12:30', '19:30']);
    expect(plan.nextMeal(DateTime(2026, 1, 1, 10))!.type, MealType.lunch);
    expect(plan.nextMeal(DateTime(2026, 1, 1, 12, 30))!.type, MealType.lunch);
    expect(plan.nextMeal(DateTime(2026, 1, 1, 22))!.type, MealType.breakfast);
  });

  test('editar cardápio salva, persiste e reagenda lembretes', () async {
    final reminders = FakeReminders();
    final state = await buildState(reminders: reminders);
    await state.setRemindersEnabled(true);
    final edited = state.mealPlan.copyWith(
      patientName: 'Maria',
      waterTargetMl: 2500,
      meals: state.mealPlan.meals.take(2).toList(),
    );
    await state.updateMealPlan(edited);
    expect(reminders.scheduledCount, 2);

    final reopened = await reopen();
    expect(reopened.mealPlan.patientName, 'Maria');
    expect(reopened.mealPlan.waterTargetMl, 2500);
    expect(reopened.mealPlan.meals, hasLength(2));
  });

  test('receitas da nutricionista: criar, editar, excluir e persistir', () async {
    final state = await buildState();
    final sampleCount = state.recipes.length;
    final id = state.newRecipeId();
    Recipe recipe(String title) => Recipe(
          id: id, title: title, category: RecipeCategory.sweet,
          ingredients: const ['a'], steps: const ['b'],
          kcalPerServing: 100, servings: 1, prepMinutes: 5, isCustom: true,
        );

    state.saveRecipe(recipe('Bolo de caneca'));
    state.toggleFavorite(id);
    expect(state.recipes.first.title, 'Bolo de caneca');
    state.saveRecipe(recipe('Bolo de caneca fit'));
    expect(state.recipes, hasLength(sampleCount + 1));

    final reopened = await reopen();
    expect(reopened.recipeById(id)!.title, 'Bolo de caneca fit');
    expect(reopened.recipeById(id)!.isCustom, isTrue);

    reopened.deleteRecipe(id);
    expect(reopened.recipeById(id), isNull);
    expect(reopened.isFavorite(id), isFalse);
  });

  test('água por dia, sem ficar negativa, e persistida', () async {
    final state = await buildState();
    final day = DateTime(2026, 11, 11, 15);
    state.addWater(day, 250);
    state.addWater(day, 250);
    state.addWater(day, -100);
    expect(state.waterFor(DateTime(2026, 11, 11)), 400);
    state.addWater(day, -1000);
    expect(state.waterFor(day), 0);
    state.addWater(day, 500);
    expect(state.waterFor(DateTime(2026, 11, 10)), 0);
    expect((await reopen()).waterFor(day), 500);
  });

  test('histórico de calorias dos últimos 7 dias', () async {
    final state = await buildState();
    final today = DateTime(2026, 11, 11, 20);
    state.addDiaryEntry(food: rice, grams: 100, meal: MealType.lunch, date: DateTime(2026, 11, 11));
    state.addDiaryEntry(food: rice, grams: 200, meal: MealType.lunch, date: DateTime(2026, 11, 9));
    state.addDiaryEntry(food: rice, grams: 100, meal: MealType.lunch, date: DateTime(2026, 11, 1));
    final history = state.kcalHistory(today);
    expect(history, hasLength(7));
    expect(history.first.$1, DateTime(2026, 11, 5));
    expect(history.last.$2, closeTo(128, 0.01));
    expect(history[4].$2, closeTo(256, 0.01));
    expect(history.map((h) => h.$2).reduce((a, b) => a + b), closeTo(384, 0.01));
  });
}
