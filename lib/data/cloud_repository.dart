import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/chat_message.dart';
import '../models/diary_entry.dart';
import '../models/meal_plan.dart';
import '../models/patient_profile.dart';
import '../models/recipe.dart';
import '../state/patient_backend.dart';
import '../utils/day_key.dart';

/// Acesso ao Firestore. Estrutura descrita em docs/MODELO_DE_DADOS.md.
class CloudRepository {
  CloudRepository([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Dias de diário/água sincronizados com o aparelho.
  static const historyDays = 60;

  DocumentReference<Map<String, dynamic>> get _clinic => _db.doc('config/clinic');
  CollectionReference<Map<String, dynamic>> get _patients => _db.collection('patients');
  CollectionReference<Map<String, dynamic>> get _recipes => _db.collection('recipes');

  DocumentReference<Map<String, dynamic>> patientDoc(String uid) => _patients.doc(uid);

  // ------------------------------------------------------------------ papéis

  /// E-mail da nutricionista cadastrado em config/clinic (ou null).
  Future<String?> nutritionistEmail() async {
    final snap = await _clinic.get();
    return snap.data()?['nutritionistEmail'] as String?;
  }

  Future<bool> patientExists(String uid) async => (await patientDoc(uid).get()).exists;

  // ------------------------------------------------------------------ pacientes

  Stream<List<PatientProfile>> patients() => _patients.snapshots().map((s) {
        final list = s.docs.map((d) => _profileFrom(d.id, d.data())).toList();
        // Não lidas primeiro, depois por nome.
        list.sort((a, b) {
          if (a.hasUnread != b.hasUnread) return a.hasUnread ? -1 : 1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        return list;
      });

  Stream<PatientProfile?> patient(String uid) =>
      patientDoc(uid).snapshots().map((d) => d.exists ? _profileFrom(d.id, d.data()!) : null);

  /// Cria a conta de login do paciente e o cadastro, sem deslogar a nutricionista.
  ///
  /// Usa uma instância secundária do Firebase só para criar o usuário.
  Future<String> createPatient({
    required String name,
    required String email,
    required String temporaryPassword,
    required MealPlan initialPlan,
  }) async {
    final secondary = await Firebase.initializeApp(
      name: 'cadastro-${DateTime.now().microsecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    try {
      final auth = FirebaseAuth.instanceFor(app: secondary);
      final cred = await auth.createUserWithEmailAndPassword(email: email, password: temporaryPassword);
      final uid = cred.user!.uid;
      await auth.signOut();
      await patientDoc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'mealPlan': initialPlan.toJson(),
      });
      return uid;
    } finally {
      await secondary.delete();
    }
  }

  Future<void> saveMealPlan(String uid, MealPlan plan) =>
      patientDoc(uid).update({'mealPlan': plan.toJson()});

  Future<void> markReadByNutri(String uid) =>
      patientDoc(uid).update({'nutriReadAt': FieldValue.serverTimestamp()});

  // ------------------------------------------------------------------ receitas

  Stream<List<Recipe>> recipes() => _recipes.snapshots().map((s) {
        final list = s.docs.map((d) => Recipe.fromJson({...d.data(), 'id': d.id, 'isCustom': true})).toList();
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        return list;
      });

  Future<void> saveRecipe(Recipe recipe) =>
      _recipes.doc(recipe.id).set(recipe.toJson()..remove('id'));

  Future<void> deleteRecipe(String id) => _recipes.doc(id).delete();

  // ------------------------------------------------------------------ diário / água

  Stream<List<DiaryEntry>> diary(String uid, {int days = historyDays}) => patientDoc(uid)
      .collection('diary')
      .where('day', isGreaterThanOrEqualTo: dayKey(DateTime.now().subtract(Duration(days: days))))
      .snapshots()
      .map((s) => s.docs.map((d) => DiaryEntry.fromJson({...d.data(), 'id': d.id})).toList());

  Future<void> addDiaryEntry(String uid, DiaryEntry e) => patientDoc(uid)
      .collection('diary')
      .doc(e.id)
      .set({...e.toJson()..remove('id'), 'day': dayKey(e.date)});

  Future<void> deleteDiaryEntry(String uid, String id) =>
      patientDoc(uid).collection('diary').doc(id).delete();

  Stream<Map<String, int>> water(String uid, {int days = historyDays}) => patientDoc(uid)
      .collection('water')
      .where(FieldPath.documentId,
          isGreaterThanOrEqualTo: dayKey(DateTime.now().subtract(Duration(days: days))))
      .snapshots()
      .map((s) => {for (final d in s.docs) d.id: (d.data()['ml'] as num? ?? 0).toInt()});

  Future<void> setWater(String uid, String day, int ml) => patientDoc(uid)
      .collection('water')
      .doc(day)
      .set({'ml': ml, 'updatedAt': FieldValue.serverTimestamp()});

  // ------------------------------------------------------------------ chat

  Stream<List<ChatMessage>> messages(String uid, {int limit = 300}) => patientDoc(uid)
      .collection('messages')
      .orderBy('sentAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.reversed.map((d) {
            final data = d.data();
            final sentAt = data['sentAt'];
            return ChatMessage.fromJson({
              ...data,
              'id': d.id,
              'sentAt': (sentAt is Timestamp ? sentAt.toDate() : DateTime.now()).toIso8601String(),
            });
          }).toList());

  Future<void> sendMessage(String uid, ChatMessage m) async {
    final batch = _db.batch();
    batch.set(patientDoc(uid).collection('messages').doc(m.id), {
      ...m.toJson()..remove('id'),
      'sentAt': Timestamp.fromDate(m.sentAt),
    });
    if (m.author == MessageAuthor.patient) {
      batch.update(patientDoc(uid), {'lastPatientMessageAt': Timestamp.fromDate(m.sentAt)});
    }
    await batch.commit();
  }

  Future<void> touchLastSeen(String uid) =>
      patientDoc(uid).update({'lastSeenAt': FieldValue.serverTimestamp()});

  // ------------------------------------------------------------------ util

  static DateTime? _date(Object? v) => v is Timestamp ? v.toDate() : null;

  static PatientProfile _profileFrom(String uid, Map<String, dynamic> d) => PatientProfile(
        uid: uid,
        name: d['name'] as String? ?? 'Paciente',
        email: d['email'] as String? ?? '',
        mealPlan: d['mealPlan'] == null
            ? null
            : MealPlan.fromJson(Map<String, dynamic>.from(d['mealPlan'] as Map)),
        createdAt: _date(d['createdAt']),
        lastSeenAt: _date(d['lastSeenAt']),
        lastPatientMessageAt: _date(d['lastPatientMessageAt']),
        nutriReadAt: _date(d['nutriReadAt']),
      );
}

/// [PatientBackend] do paciente logado, sobre o [CloudRepository].
class FirestorePatientBackend implements PatientBackend {
  FirestorePatientBackend(this.uid, this.repo);

  final String uid;
  final CloudRepository repo;

  @override
  Stream<MealPlan?> mealPlan() => repo.patient(uid).map((p) => p?.mealPlan);

  @override
  Stream<List<Recipe>> recipes() => repo.recipes();

  @override
  Stream<List<DiaryEntry>> diary() => repo.diary(uid);

  @override
  Stream<Map<String, int>> water() => repo.water(uid);

  @override
  Stream<List<ChatMessage>> messages() => repo.messages(uid);

  @override
  Future<void> addDiaryEntry(DiaryEntry entry) => repo.addDiaryEntry(uid, entry);

  @override
  Future<void> deleteDiaryEntry(String id) => repo.deleteDiaryEntry(uid, id);

  @override
  Future<void> setWater(String dayKey, int ml) => repo.setWater(uid, dayKey, ml);

  @override
  Future<void> sendMessage(ChatMessage message) => repo.sendMessage(uid, message);

  @override
  Future<void> touchLastSeen() => repo.touchLastSeen(uid);
}
