import '../models/chat_message.dart';
import '../models/diary_entry.dart';
import '../models/meal_plan.dart';
import '../models/recipe.dart';

/// Fonte remota dos dados do paciente logado (implementada com Firestore).
///
/// O [AppState] assina os streams e envia as alterações por estes métodos.
/// Nos testes é substituída por uma versão em memória.
abstract class PatientBackend {
  Stream<MealPlan?> mealPlan();
  Stream<List<Recipe>> recipes();
  Stream<List<DiaryEntry>> diary();
  Stream<Map<String, int>> water();
  Stream<List<ChatMessage>> messages();

  Future<void> addDiaryEntry(DiaryEntry entry);
  Future<void> deleteDiaryEntry(String id);
  Future<void> setWater(String dayKey, int ml);
  Future<void> sendMessage(ChatMessage message);
  Future<void> touchLastSeen();
}
