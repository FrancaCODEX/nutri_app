import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_app/data/sample_meal_plan.dart';
import 'package:nutri_app/models/chat_message.dart';
import 'package:nutri_app/models/diary_entry.dart';
import 'package:nutri_app/models/meal_plan.dart';
import 'package:nutri_app/models/meal_type.dart';
import 'package:nutri_app/models/patient_profile.dart';
import 'package:nutri_app/models/recipe.dart';
import 'package:nutri_app/state/patient_backend.dart';

import 'helpers/fakes.dart';

class FakeBackend implements PatientBackend {
  final plan = StreamController<MealPlan?>.broadcast();
  final recipeList = StreamController<List<Recipe>>.broadcast();
  final diaryList = StreamController<List<DiaryEntry>>.broadcast();
  final waterMap = StreamController<Map<String, int>>.broadcast();
  final messageList = StreamController<List<ChatMessage>>.broadcast();

  final addedDiary = <DiaryEntry>[];
  final deletedDiary = <String>[];
  final waterWrites = <String, int>{};
  final sent = <ChatMessage>[];
  bool touched = false;

  @override
  Stream<MealPlan?> mealPlan() => plan.stream;
  @override
  Stream<List<Recipe>> recipes() => recipeList.stream;
  @override
  Stream<List<DiaryEntry>> diary() => diaryList.stream;
  @override
  Stream<Map<String, int>> water() => waterMap.stream;
  @override
  Stream<List<ChatMessage>> messages() => messageList.stream;

  @override
  Future<void> addDiaryEntry(DiaryEntry entry) async => addedDiary.add(entry);
  @override
  Future<void> deleteDiaryEntry(String id) async => deletedDiary.add(id);
  @override
  Future<void> setWater(String dayKey, int ml) async => waterWrites[dayKey] = ml;
  @override
  Future<void> sendMessage(ChatMessage message) async => sent.add(message);
  @override
  Future<void> touchLastSeen() async => touched = true;
}

ChatMessage nutriMsg(String id, String text) => ChatMessage(
    id: id, author: MessageAuthor.nutritionist, sentAt: DateTime(2026, 11, 12), text: text);

void main() {
  test('dados da nuvem substituem os locais e o cardápio fica vazio até carregar', () async {
    final state = await buildState();
    final backend = FakeBackend();
    state.attachBackend(backend);
    expect(backend.touched, isTrue);
    expect(state.mealPlanReady, isFalse);
    expect(state.mealPlan.meals, isEmpty);
    expect(state.recipes, isEmpty, reason: 'sem receitas de exemplo quando conectado');

    backend.plan.add(sampleMealPlan);
    backend.waterMap.add({'2026-11-12': 750});
    await pumpEventQueue();
    expect(state.mealPlanReady, isTrue);
    expect(state.mealPlan.meals, isNotEmpty);
    expect(state.waterFor(DateTime(2026, 11, 12)), 750);

    backend.plan.add(null);
    await pumpEventQueue();
    expect(state.mealPlan.meals, isEmpty);
  });

  test('alterações do paciente vão para a nuvem', () async {
    final state = await buildState();
    final backend = FakeBackend();
    state.attachBackend(backend);
    final day = DateTime(2026, 11, 12);

    state.addDiaryEntry(food: rice, grams: 50, meal: MealType.lunch, date: day);
    expect(backend.addedDiary.single.grams, 50);
    state.removeDiaryEntry(backend.addedDiary.single.id);
    expect(backend.deletedDiary, [backend.addedDiary.single.id]);

    backend.waterMap.add({'2026-11-12': 500});
    await pumpEventQueue();
    state.addWater(day, 250);
    expect(backend.waterWrites['2026-11-12'], 750);

    state.sendMessage(text: 'Oi', imagePath: 'data:image/jpeg;base64,AAAA');
    expect(backend.sent.single.author, MessageAuthor.patient);
    expect(backend.sent.single.imagePath, startsWith('data:'));
  });

  test('avisa só mensagens novas da nutricionista, depois da primeira carga', () async {
    final state = await buildState();
    final backend = FakeBackend();
    final notified = <String>[];
    state.onNutritionistMessage = (m) => notified.add(m.text!);
    state.attachBackend(backend);

    backend.messageList.add([nutriMsg('1', 'antiga')]);
    await pumpEventQueue();
    expect(notified, isEmpty);

    backend.messageList.add([
      nutriMsg('1', 'antiga'),
      ChatMessage(id: '2', author: MessageAuthor.patient, sentAt: DateTime(2026), text: 'minha'),
      nutriMsg('3', 'nova'),
    ]);
    await pumpEventQueue();
    expect(notified, ['nova']);
    expect(state.messages, hasLength(3));
  });

  test('desconectar para de receber atualizações', () async {
    final state = await buildState();
    final backend = FakeBackend();
    state.attachBackend(backend);
    state.detachBackend();
    backend.waterMap.add({'2026-11-12': 999});
    await pumpEventQueue();
    expect(state.waterFor(DateTime(2026, 11, 12)), 0);
    expect(state.isConnected, isFalse);
  });

  test('não lida: mensagem do paciente depois da última leitura da nutri', () {
    final base = DateTime(2026, 11, 12, 10);
    PatientProfile p({DateTime? msg, DateTime? read}) =>
        PatientProfile(uid: 'u', name: 'A', email: 'a@a', lastPatientMessageAt: msg, nutriReadAt: read);
    expect(p().hasUnread, isFalse);
    expect(p(msg: base).hasUnread, isTrue);
    expect(p(msg: base, read: base.add(const Duration(minutes: 1))).hasUnread, isFalse);
    expect(p(msg: base.add(const Duration(minutes: 2)), read: base).hasUnread, isTrue);
  });

  test('storage: outra conta no mesmo aparelho apaga os dados locais', () async {
    final storage = await freshStorage({'diary_v1': '[]', 'owner_uid_v1': 'a'});
    await storage.claimFor('a');
    expect(storage.ownerUid, 'a');
    await storage.saveRemindersEnabled(true);
    await storage.claimFor('b');
    expect(storage.ownerUid, 'b');
    expect(storage.loadRemindersEnabled(), isFalse);
  });
}
