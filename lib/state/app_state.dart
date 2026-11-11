import 'package:flutter/material.dart';

import '../data/local_storage.dart';
import '../data/sample_meal_plan.dart';
import '../data/sample_recipes.dart';
import '../models/chat_message.dart';
import '../models/diary_entry.dart';
import '../models/food.dart';
import '../models/meal_plan.dart';
import '../models/meal_type.dart';
import '../models/recipe.dart';
import '../services/nutrition_calculator.dart';
import '../services/reminder_service.dart';
import '../services/text_search.dart';

/// Estado da aplicação.
///
/// Diário, chat, favoritos e preferências são salvos no aparelho via
/// [LocalStorage]. Na fase com Firebase a mesma interface passa a usar a nuvem.
class AppState extends ChangeNotifier {
  AppState({
    required LocalStorage storage,
    required ReminderScheduler reminders,
    required this.foods,
  })  : _storage = storage,
        _reminders = reminders,
        _diary = storage.loadDiary(),
        _favorites = storage.loadFavorites(),
        _remindersEnabled = storage.loadRemindersEnabled(),
        _mealPlan = storage.loadMealPlan() ?? sampleMealPlan,
        _customRecipes = storage.loadCustomRecipes(),
        _water = storage.loadWater() {
    final saved = storage.loadMessages();
    _messages = saved.isNotEmpty ? saved : [_welcomeMessage()];
  }

  final LocalStorage _storage;
  final ReminderScheduler _reminders;

  final List<Food> foods;

  MealPlan _mealPlan;
  final List<Recipe> _customRecipes;
  final Map<String, int> _water;

  final List<DiaryEntry> _diary;
  late final List<ChatMessage> _messages;
  final Set<String> _favorites;
  bool _remindersEnabled;

  int _idSeq = 0;
  String _nextId() => '${DateTime.now().microsecondsSinceEpoch}_${_idSeq++}';

  static ChatMessage _welcomeMessage() => ChatMessage(
        id: 'welcome',
        author: MessageAuthor.nutritionist,
        sentAt: DateTime.now(),
        text: 'Oi! Qualquer dúvida sobre o cardápio, me chama por aqui.',
      );

  // ---------------------------------------------------------------- cardápio

  MealPlan get mealPlan => _mealPlan;

  /// Substitui o cardápio (área da nutricionista) e reagenda os lembretes.
  Future<void> updateMealPlan(MealPlan plan) async {
    _mealPlan = plan;
    await _storage.saveMealPlan(plan);
    notifyListeners();
    await refreshReminders();
  }

  // ---------------------------------------------------------------- receitas

  /// Receitas criadas pela nutricionista primeiro, depois as de exemplo.
  List<Recipe> get recipes => [..._customRecipes.reversed, ...sampleRecipes];

  String newRecipeId() => 'r_${_nextId()}';

  /// Cria ou atualiza uma receita da nutricionista.
  void saveRecipe(Recipe recipe) {
    final i = _customRecipes.indexWhere((r) => r.id == recipe.id);
    if (i >= 0) {
      _customRecipes[i] = recipe;
    } else {
      _customRecipes.add(recipe);
    }
    _storage.saveCustomRecipes(_customRecipes);
    notifyListeners();
  }

  void deleteRecipe(String id) {
    _customRecipes.removeWhere((r) => r.id == id);
    _favorites.remove(id);
    _storage.saveCustomRecipes(_customRecipes);
    _storage.saveFavorites(_favorites);
    notifyListeners();
  }

  Recipe? recipeById(String id) {
    for (final r in recipes) {
      if (r.id == id) return r;
    }
    return null;
  }

  bool isFavorite(String recipeId) => _favorites.contains(recipeId);

  void toggleFavorite(String recipeId) {
    if (!_favorites.remove(recipeId)) _favorites.add(recipeId);
    _storage.saveFavorites(_favorites);
    notifyListeners();
  }

  // ---------------------------------------------------------------- alimentos

  List<Food> searchFoods(String query, {int limit = 60}) =>
      TextSearch.rank(foods, query, (f) => f.name, limit: limit);

  /// Alimentos registrados recentemente (sem repetição), para atalho rápido.
  List<Food> recentFoods({int limit = 8}) {
    final seen = <String>{};
    final result = <Food>[];
    for (final e in _diary.reversed) {
      if (seen.add(e.food.id)) result.add(e.food);
      if (result.length == limit) break;
    }
    return result;
  }

  // ---------------------------------------------------------------- diário

  List<DiaryEntry> entriesFor(DateTime day) => _diary
      .where((e) => DateUtils.isSameDay(e.date, day))
      .toList(growable: false);

  void addDiaryEntry({
    required Food food,
    required double grams,
    required MealType meal,
    required DateTime date,
    String? portionLabel,
  }) {
    _diary.add(DiaryEntry(
      id: _nextId(),
      food: food,
      grams: grams,
      meal: meal,
      date: date,
      portionLabel: portionLabel,
    ));
    _storage.saveDiary(_diary);
    notifyListeners();
  }

  void removeDiaryEntry(String id) {
    _diary.removeWhere((e) => e.id == id);
    _storage.saveDiary(_diary);
    notifyListeners();
  }

  /// Desfaz uma remoção.
  void restoreDiaryEntry(DiaryEntry entry) {
    _diary.add(entry);
    _storage.saveDiary(_diary);
    notifyListeners();
  }

  /// Total de kcal por dia nos últimos [days] dias (mais antigo primeiro).
  List<(DateTime, double)> kcalHistory(DateTime today, {int days = 7}) {
    final base = DateUtils.dateOnly(today);
    return [
      for (var i = days - 1; i >= 0; i--)
        () {
          final day = base.subtract(Duration(days: i));
          return (day, NutritionCalculator.total(entriesFor(day)).kcal);
        }(),
    ];
  }

  // ---------------------------------------------------------------- água

  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int waterFor(DateTime day) => _water[_dayKey(day)] ?? 0;

  /// Soma (ou subtrai, se negativo) água do dia, sem ficar abaixo de zero.
  void addWater(DateTime day, int ml) {
    final key = _dayKey(day);
    final next = ((_water[key] ?? 0) + ml).clamp(0, 10000);
    _water[key] = next;
    _storage.saveWater(_water);
    notifyListeners();
  }

  // ---------------------------------------------------------------- chat

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void sendMessage({String? text, String? imagePath}) {
    final trimmed = text?.trim();
    final hasText = trimmed != null && trimmed.isNotEmpty;
    if (!hasText && imagePath == null) return;
    _messages.add(ChatMessage(
      id: _nextId(),
      author: MessageAuthor.patient,
      sentAt: DateTime.now(),
      text: hasText ? trimmed : null,
      imagePath: imagePath,
    ));
    _storage.saveMessages(_messages);
    notifyListeners();
  }

  // ---------------------------------------------------------------- lembretes

  bool get remindersEnabled => _remindersEnabled;

  /// Liga/desliga os lembretes. Retorna `false` se a permissão foi negada.
  Future<bool> setRemindersEnabled(bool enabled) async {
    if (enabled) {
      final granted = await _reminders.requestPermission();
      if (!granted) return false;
      await _reminders.scheduleMeals(_mealPlan.sortedMeals);
    } else {
      await _reminders.cancelAll();
    }
    _remindersEnabled = enabled;
    await _storage.saveRemindersEnabled(enabled);
    notifyListeners();
    return true;
  }

  /// Reagenda os lembretes ao abrir o app (horários podem ter mudado).
  Future<void> refreshReminders() async {
    if (_remindersEnabled) await _reminders.scheduleMeals(_mealPlan.sortedMeals);
  }
}

/// Disponibiliza o [AppState] para a árvore de widgets.
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.notifier!;

  /// Acesso sem se registrar para reconstrução (usar em callbacks).
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppStateScope>()!.notifier!;
}
