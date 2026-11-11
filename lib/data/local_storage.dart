import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';
import '../models/diary_entry.dart';
import '../models/meal_plan.dart';
import '../models/recipe.dart';

/// Persistência local (no aparelho) dos dados do paciente.
///
/// Na fase com Firebase estes dados passam a ser sincronizados na nuvem.
class LocalStorage {
  LocalStorage(this._prefs);

  static const _diaryKey = 'diary_v1';
  static const _messagesKey = 'messages_v1';
  static const _favoritesKey = 'favorite_recipes_v1';
  static const _remindersKey = 'meal_reminders_enabled_v1';
  static const _mealPlanKey = 'meal_plan_v1';
  static const _recipesKey = 'custom_recipes_v1';
  static const _waterKey = 'water_ml_by_day_v1';

  final SharedPreferences _prefs;

  static Future<LocalStorage> open() async =>
      LocalStorage(await SharedPreferences.getInstance());

  List<DiaryEntry> loadDiary() => _decodeList(_diaryKey, DiaryEntry.fromJson);

  Future<void> saveDiary(List<DiaryEntry> entries) =>
      _prefs.setString(_diaryKey, jsonEncode(entries.map((e) => e.toJson()).toList()));

  List<ChatMessage> loadMessages() => _decodeList(_messagesKey, ChatMessage.fromJson);

  Future<void> saveMessages(List<ChatMessage> messages) =>
      _prefs.setString(_messagesKey, jsonEncode(messages.map((m) => m.toJson()).toList()));

  Set<String> loadFavorites() => (_prefs.getStringList(_favoritesKey) ?? const []).toSet();

  Future<void> saveFavorites(Set<String> ids) => _prefs.setStringList(_favoritesKey, ids.toList());

  bool loadRemindersEnabled() => _prefs.getBool(_remindersKey) ?? false;

  Future<void> saveRemindersEnabled(bool enabled) => _prefs.setBool(_remindersKey, enabled);

  MealPlan? loadMealPlan() {
    final raw = _prefs.getString(_mealPlanKey);
    if (raw == null) return null;
    try {
      return MealPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

  Future<void> saveMealPlan(MealPlan plan) =>
      _prefs.setString(_mealPlanKey, jsonEncode(plan.toJson()));

  List<Recipe> loadCustomRecipes() => _decodeList(_recipesKey, Recipe.fromJson);

  Future<void> saveCustomRecipes(List<Recipe> recipes) =>
      _prefs.setString(_recipesKey, jsonEncode(recipes.map((r) => r.toJson()).toList()));

  /// Água consumida por dia, em ml. Chave: "yyyy-MM-dd".
  Map<String, int> loadWater() {
    final raw = _prefs.getString(_waterKey);
    if (raw == null) return {};
    try {
      return (jsonDecode(raw) as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toInt()));
    } on FormatException {
      return {};
    }
  }

  Future<void> saveWater(Map<String, int> water) => _prefs.setString(_waterKey, jsonEncode(water));

  List<T> _decodeList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } on Object {
      return [];
    }
  }
}
