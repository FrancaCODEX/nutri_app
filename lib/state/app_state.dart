import 'package:flutter/material.dart';

import '../data/sample_meal_plan.dart';
import '../data/sample_recipes.dart';
import '../data/taco_foods.dart';
import '../models/chat_message.dart';
import '../models/diary_entry.dart';
import '../models/food.dart';
import '../models/meal_plan.dart';
import '../models/meal_type.dart';
import '../models/recipe.dart';

/// Estado da aplicação, mantido em memória.
///
/// Na fase 2 (ver docs/ROADMAP.md) os dados passam a vir do Firebase;
/// as telas continuam usando esta mesma interface.
class AppState extends ChangeNotifier {
  final MealPlan mealPlan = sampleMealPlan;
  final List<Recipe> recipes = List.of(sampleRecipes);
  final List<Food> foods = tacoFoods;
  final List<DiaryEntry> _diary = [];
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'm0',
      author: MessageAuthor.nutritionist,
      sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      text: 'Oi! Qualquer dúvida sobre o cardápio, me chama por aqui.',
    ),
  ];

  int _idSeq = 0;
  String _nextId() => '${DateTime.now().microsecondsSinceEpoch}_${_idSeq++}';

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Recipe? recipeById(String id) {
    for (final r in recipes) {
      if (r.id == id) return r;
    }
    return null;
  }

  List<Food> searchFoods(String query) {
    final q = _normalize(query.trim());
    if (q.isEmpty) return foods;
    return foods.where((f) => _normalize(f.name).contains(q)).toList();
  }

  List<DiaryEntry> entriesFor(DateTime day) => _diary
      .where((e) => DateUtils.isSameDay(e.date, day))
      .toList(growable: false);

  void addDiaryEntry({
    required Food food,
    required double grams,
    required MealType meal,
    required DateTime date,
  }) {
    _diary.add(DiaryEntry(id: _nextId(), food: food, grams: grams, meal: meal, date: date));
    notifyListeners();
  }

  void removeDiaryEntry(String id) {
    _diary.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void sendMessage({String? text, String? imagePath}) {
    if ((text == null || text.trim().isEmpty) && imagePath == null) return;
    _messages.add(ChatMessage(
      id: _nextId(),
      author: MessageAuthor.patient,
      sentAt: DateTime.now(),
      text: text?.trim().isEmpty ?? true ? null : text!.trim(),
      imagePath: imagePath,
    ));
    notifyListeners();
  }

  static String _normalize(String s) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const to = 'aaaaaeeeeiiiiooooouuuuc';
    final lower = s.toLowerCase();
    final buffer = StringBuffer();
    for (final ch in lower.split('')) {
      final i = from.indexOf(ch);
      buffer.write(i >= 0 ? to[i] : ch);
    }
    return buffer.toString();
  }
}

/// Disponibiliza o [AppState] para a árvore de widgets.
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.notifier!;
}
