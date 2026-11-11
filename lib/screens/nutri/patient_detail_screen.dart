import 'package:flutter/material.dart';

import '../../data/cloud_repository.dart';
import '../../models/chat_message.dart';
import '../../models/diary_entry.dart';
import '../../models/meal_plan.dart';
import '../../models/meal_type.dart';
import '../../models/patient_profile.dart';
import '../../models/recipe.dart';
import '../../services/nutrition_calculator.dart';
import '../../utils/day_key.dart';
import '../../widgets/chat_view.dart';
import '../../widgets/weekly_chart.dart';
import 'meal_plan_editor_screen.dart';

/// Paciente visto pela nutricionista: chat, cardápio e acompanhamento.
class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({
    super.key,
    required this.repo,
    required this.uid,
    required this.recipes,
    this.openChat = false,
  });

  final CloudRepository repo;
  final String uid;
  final Stream<List<Recipe>> recipes;
  final bool openChat;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late final _profile = widget.repo.patient(widget.uid);
  late final _messages = widget.repo.messages(widget.uid);
  late final _diary = widget.repo.diary(widget.uid, days: 14);
  late final _water = widget.repo.water(widget.uid, days: 14);

  @override
  void initState() {
    super.initState();
    widget.repo.markReadByNutri(widget.uid).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PatientProfile?>(
      stream: _profile,
      builder: (context, snap) {
        final profile = snap.data;
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: snap.connectionState == ConnectionState.waiting
                  ? const CircularProgressIndicator()
                  : const Text('Paciente não encontrado.'),
            ),
          );
        }
        if (profile.hasUnread) widget.repo.markReadByNutri(widget.uid).catchError((_) {});
        return DefaultTabController(
          length: 3,
          initialIndex: widget.openChat ? 0 : 1,
          child: Scaffold(
            appBar: AppBar(
              title: Text(profile.name),
              bottom: const TabBar(tabs: [
                Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chat'),
                Tab(icon: Icon(Icons.restaurant_menu), text: 'Cardápio'),
                Tab(icon: Icon(Icons.insights), text: 'Acompanhamento'),
              ]),
            ),
            body: TabBarView(
              children: [
                StreamBuilder<List<ChatMessage>>(
                  stream: _messages,
                  builder: (context, s) => ChatView(
                    messages: s.data ?? const [],
                    viewer: MessageAuthor.nutritionist,
                    emptyText: 'Nenhuma mensagem com ${profile.name} ainda.',
                    onSend: (text, image) => widget.repo.sendMessage(
                      widget.uid,
                      ChatMessage(
                        id: 'm_${DateTime.now().microsecondsSinceEpoch}',
                        author: MessageAuthor.nutritionist,
                        sentAt: DateTime.now(),
                        text: text,
                        imagePath: image,
                      ),
                    ),
                  ),
                ),
                _PlanTab(profile: profile, repo: widget.repo, recipes: widget.recipes),
                _TrackingTab(profile: profile, diary: _diary, water: _water),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlanTab extends StatelessWidget {
  const _PlanTab({required this.profile, required this.repo, required this.recipes});

  final PatientProfile profile;
  final CloudRepository repo;
  final Stream<List<Recipe>> recipes;

  @override
  Widget build(BuildContext context) {
    final plan = profile.mealPlan ?? MealPlan.empty(patientName: profile.name);
    return StreamBuilder<List<Recipe>>(
      stream: recipes,
      builder: (context, snap) {
        final recipeList = snap.data ?? const <Recipe>[];
        String recipeTitle(String id) =>
            recipeList.where((r) => r.id == id).map((r) => r.title).firstOrNull ?? 'receita removida';
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.meals.isEmpty
                        ? 'Cardápio ainda não montado.'
                        : 'Meta ${plan.kcalTarget.round()} kcal · água ${plan.waterTargetMl} ml',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.icon(
                  icon: Icon(plan.meals.isEmpty ? Icons.add : Icons.edit),
                  label: Text(plan.meals.isEmpty ? 'Montar' : 'Editar'),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => MealPlanEditorScreen(
                      initial: plan,
                      recipes: recipeList,
                      onSave: (p) => repo.saveMealPlan(profile.uid, p),
                    ),
                  )),
                ),
              ],
            ),
            if (plan.generalNotes?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(plan.generalNotes!),
              ),
            const SizedBox(height: 8),
            for (final m in plan.sortedMeals)
              Card(
                child: ListTile(
                  title: Text('${m.time} · ${m.type.label}'),
                  subtitle: Text([
                    m.main.description,
                    for (final a in m.alternatives) 'ou ${a.description}',
                    for (final id in {...m.main.recipeIds, ...m.alternatives.expand((a) => a.recipeIds)})
                      '📖 ${recipeTitle(id)}',
                  ].join('\n')),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TrackingTab extends StatelessWidget {
  const _TrackingTab({required this.profile, required this.diary, required this.water});

  final PatientProfile profile;
  final Stream<List<DiaryEntry>> diary;
  final Stream<Map<String, int>> water;

  @override
  Widget build(BuildContext context) {
    final target = profile.mealPlan?.kcalTarget ?? 2000;
    final waterTarget = profile.mealPlan?.waterTargetMl ?? 2000;
    final today = DateUtils.dateOnly(DateTime.now());
    return StreamBuilder<List<DiaryEntry>>(
      stream: diary,
      builder: (context, diarySnap) => StreamBuilder<Map<String, int>>(
        stream: water,
        builder: (context, waterSnap) {
          if (!diarySnap.hasData) return const Center(child: CircularProgressIndicator());
          final entries = diarySnap.data!;
          final waterMap = waterSnap.data ?? const {};
          List<DiaryEntry> on(DateTime d) => entries.where((e) => DateUtils.isSameDay(e.date, d)).toList();
          final days = [for (var i = 6; i >= 0; i--) today.subtract(Duration(days: i))];
          final history = [for (final d in days) (d, NutritionCalculator.total(on(d)).kcal)];
          final daysWithRecord = history.where((h) => h.$2 > 0).length;
          final todayEntries = on(today);
          final text = Theme.of(context).textTheme;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Últimos 7 dias', style: text.titleMedium),
                      Text('$daysWithRecord de 7 dias com registro', style: text.bodySmall),
                      const SizedBox(height: 12),
                      WeeklyChart(data: history, target: target),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Água (meta $waterTarget ml)', style: text.titleMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final d in days)
                            Expanded(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.water_drop,
                                    color: (waterMap[dayKey(d)] ?? 0) >= waterTarget
                                        ? Colors.blue
                                        : Colors.blue.withValues(alpha: 0.25),
                                  ),
                                  Text(((waterMap[dayKey(d)] ?? 0) / 1000).toStringAsFixed(1),
                                      style: text.labelSmall),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
                child: Text('Hoje', style: text.titleMedium),
              ),
              if (todayEntries.isEmpty) const Padding(padding: EdgeInsets.all(4), child: Text('Nada registrado hoje.')),
              for (final meal in MealType.values)
                for (final e in todayEntries.where((e) => e.meal == meal))
                  ListTile(
                    dense: true,
                    title: Text(e.food.name),
                    subtitle: Text('${meal.label} · ${e.portionLabel ?? '${e.grams.round()} g'}'),
                    trailing: Text('${NutritionCalculator.forPortion(e.food, e.grams).kcal.round()} kcal'),
                  ),
            ],
          );
        },
      ),
    );
  }
}
