import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_app/data/local_storage.dart';
import 'package:nutri_app/models/meal_type.dart';
import 'package:nutri_app/state/app_state.dart';

import 'helpers/fakes.dart';

void main() {
  final day = DateTime(2026, 11, 10);

  test('diário é salvo e recarregado do armazenamento', () async {
    final state = await buildState();
    state.addDiaryEntry(food: rice, grams: 50, meal: MealType.lunch, date: day,
        portionLabel: '2 colher de sopa');

    // Simula reabrir o app com o mesmo armazenamento.
    final reopened = AppState(
      storage: await LocalStorage.open(),
      reminders: FakeReminders(),
      foods: const [rice],
    );
    final entries = reopened.entriesFor(day);
    expect(entries, hasLength(1));
    expect(entries.single.food.name, rice.name);
    expect(entries.single.portionLabel, '2 colher de sopa');
  });

  test('remover e desfazer registro do diário', () async {
    final state = await buildState();
    state.addDiaryEntry(food: rice, grams: 100, meal: MealType.lunch, date: day);
    final entry = state.entriesFor(day).single;
    state.removeDiaryEntry(entry.id);
    expect(state.entriesFor(day), isEmpty);
    state.restoreDiaryEntry(entry);
    expect(state.entriesFor(day), hasLength(1));
  });

  test('favoritos alternam e persistem', () async {
    final state = await buildState();
    state.toggleFavorite('r1');
    expect(state.isFavorite('r1'), isTrue);
    final reopened = AppState(
      storage: await LocalStorage.open(), reminders: FakeReminders(), foods: const []);
    expect(reopened.isFavorite('r1'), isTrue);
    reopened.toggleFavorite('r1');
    expect(reopened.isFavorite('r1'), isFalse);
  });

  test('mensagens do chat persistem, incluindo fotos', () async {
    final state = await buildState();
    state.sendMessage(text: '  ');
    state.sendMessage(text: 'Posso trocar o arroz?');
    state.sendMessage(imagePath: '/fotos/prato.jpg');
    final reopened = AppState(
      storage: await LocalStorage.open(), reminders: FakeReminders(), foods: const []);
    final mine = reopened.messages.where((m) => m.id != 'welcome').toList();
    expect(mine.map((m) => m.text), ['Posso trocar o arroz?', null]);
    expect(mine.last.imagePath, '/fotos/prato.jpg');
  });

  test('lembretes: agenda ao ligar, cancela ao desligar, respeita permissão', () async {
    final reminders = FakeReminders();
    final state = await buildState(reminders: reminders);
    expect(await state.setRemindersEnabled(true), isTrue);
    expect(reminders.scheduledCount, state.mealPlan.meals.length);
    expect(state.remindersEnabled, isTrue);
    await state.setRemindersEnabled(false);
    expect(reminders.cancelled, isTrue);

    final denied = await buildState(reminders: FakeReminders(grant: false));
    expect(await denied.setRemindersEnabled(true), isFalse);
    expect(denied.remindersEnabled, isFalse);
  });

  test('alimentos recentes sem repetição, mais recente primeiro', () async {
    final state = await buildState();
    state.addDiaryEntry(food: rice, grams: 100, meal: MealType.lunch, date: day);
    state.addDiaryEntry(food: chicken, grams: 100, meal: MealType.lunch, date: day);
    state.addDiaryEntry(food: rice, grams: 50, meal: MealType.dinner, date: day);
    expect(state.recentFoods().map((f) => f.id), [rice.id, chicken.id]);
  });
}
