import 'package:nutri_app/data/local_storage.dart';
import 'package:nutri_app/models/food.dart';
import 'package:nutri_app/models/meal_plan.dart';
import 'package:nutri_app/services/reminder_service.dart';
import 'package:nutri_app/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeReminders implements ReminderScheduler {
  FakeReminders({this.grant = true});

  final bool grant;
  int scheduledCount = 0;
  bool cancelled = false;

  @override
  Future<bool> requestPermission() async => grant;

  @override
  Future<void> scheduleMeals(List<PlannedMeal> meals) async => scheduledCount = meals.length;

  @override
  Future<void> cancelAll() async => cancelled = true;
}

const rice = Food(
  id: 'taco_3', name: 'Arroz, tipo 1, cozido', category: 'Cereais e derivados',
  kcalPer100g: 128, proteinPer100g: 2.5, carbsPer100g: 28.1, fatPer100g: 0.2,
);

const chicken = Food(
  id: 'taco_x', name: 'Frango, peito, sem pele, grelhado', category: 'Carnes e derivados',
  kcalPer100g: 159, proteinPer100g: 32, carbsPer100g: 0, fatPer100g: 2.5,
);

Future<LocalStorage> freshStorage([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return LocalStorage.open();
}

Future<AppState> buildState({
  List<Food> foods = const [rice, chicken],
  ReminderScheduler? reminders,
}) async =>
    AppState(storage: await freshStorage(), reminders: reminders ?? FakeReminders(), foods: foods);
