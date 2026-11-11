import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/nutrition_calculator.dart';
import '../state/app_state.dart';
import '../widgets/weekly_chart.dart';

/// Resumo do dia: calorias, água, próxima refeição e evolução da semana.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.onOpenMealPlan, required this.onOpenDiary});

  final VoidCallback onOpenMealPlan;
  final VoidCallback onOpenDiary;

  static const glassMl = 250;

  String _greeting(DateTime now) {
    if (now.hour < 12) return 'Bom dia';
    if (now.hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final plan = state.mealPlan;
    final total = NutritionCalculator.total(state.entriesFor(today));
    final kcalProgress = plan.kcalTarget <= 0 ? 0.0 : (total.kcal / plan.kcalTarget).clamp(0.0, 1.0);
    final water = state.waterFor(today);
    final waterProgress = (water / plan.waterTargetMl).clamp(0.0, 1.0);
    final next = plan.nextMeal(now);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              children: [
                Image.asset('assets/icon/logo_mark.png', height: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting(now), style: text.titleLarge),
                      Text(DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(now),
                          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Calorias
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onOpenDiary,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 96,
                        height: 96,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: kcalProgress,
                              strokeWidth: 10,
                              strokeCap: StrokeCap.round,
                              backgroundColor: scheme.surfaceContainerHighest,
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${total.kcal.round()}', style: text.titleLarge),
                                  Text('kcal', style: text.labelSmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Calorias de hoje', style: text.titleMedium),
                            Text(
                              total.kcal <= plan.kcalTarget
                                  ? 'Faltam ${(plan.kcalTarget - total.kcal).round()} kcal da meta'
                                  : '${(total.kcal - plan.kcalTarget).round()} kcal acima da meta',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'P ${total.protein.round()} g · C ${total.carbs.round()} g · G ${total.fat.round()} g',
                              style: text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Água
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.water_drop, color: Colors.blue.shade400),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Água', style: text.titleMedium)),
                        Text('${(water / 1000).toStringAsFixed(2).replaceAll('.', ',')} / '
                            '${(plan.waterTargetMl / 1000).toStringAsFixed(1).replaceAll('.', ',')} L'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: waterProgress,
                        minHeight: 10,
                        color: Colors.blue.shade400,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton.outlined(
                          tooltip: 'Remover copo',
                          onPressed: water == 0 ? null : () => state.addWater(today, -glassMl),
                          icon: const Icon(Icons.remove),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => state.addWater(today, glassMl),
                            icon: const Icon(Icons.local_drink_outlined),
                            label: const Text('+ 1 copo (250 ml)'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Próxima refeição
            if (next != null)
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(Icons.restaurant, color: scheme.onPrimaryContainer),
                  ),
                  title: Text('Próxima: ${next.type.label} · ${next.time}'),
                  subtitle: Text(
                    next.alternatives.isEmpty
                        ? next.main.description
                        : '${next.main.description}\n+ ${next.alternatives.length} opção(ões) alternativa(s)',
                  ),
                  isThreeLine: next.alternatives.isNotEmpty,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: onOpenMealPlan,
                ),
              ),

            // Semana
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Últimos 7 dias', style: text.titleMedium),
                    const SizedBox(height: 12),
                    WeeklyChart(data: state.kcalHistory(today), target: plan.kcalTarget),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
