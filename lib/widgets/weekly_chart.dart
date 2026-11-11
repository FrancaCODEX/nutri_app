import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Gráfico de barras simples das calorias dos últimos dias, com linha de meta.
class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key, required this.data, required this.target});

  final List<(DateTime, double)> data;
  final double target;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final maxValue = [target * 1.2, ...data.map((d) => d.$2)].reduce((a, b) => a > b ? a : b);
    const barAreaHeight = 120.0;
    final targetY = barAreaHeight * (target / maxValue);

    return Column(
      children: [
        SizedBox(
          height: barAreaHeight + 20,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: targetY,
                child: Row(
                  children: [
                    Expanded(child: Divider(color: scheme.outline, height: 1)),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text('meta', style: text.labelSmall),
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final (_, kcal) in data)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (kcal > 0) Text('${kcal.round()}', style: text.labelSmall),
                          const SizedBox(height: 2),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            height: kcal <= 0 ? 3 : (barAreaHeight * kcal / maxValue).clamp(3, barAreaHeight),
                            decoration: BoxDecoration(
                              color: kcal > target * 1.1 ? scheme.tertiary : scheme.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 28),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (final (day, _) in data)
              Expanded(
                child: Text(
                  DateFormat('E', 'pt_BR').format(day).substring(0, 3),
                  textAlign: TextAlign.center,
                  style: text.labelSmall,
                ),
              ),
            const SizedBox(width: 28),
          ],
        ),
      ],
    );
  }
}
