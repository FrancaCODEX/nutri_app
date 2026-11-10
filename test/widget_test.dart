import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nutri_app/app.dart';
import 'package:nutri_app/state/app_state.dart';

import 'helpers/fakes.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('navega pelas abas e registra alimento com medida caseira', (tester) async {
    final state = await buildState();
    await tester.pumpWidget(AppStateScope(state: state, child: const NutriApp()));
    expect(find.text('Meu cardápio'), findsOneWidget);

    await tester.tap(find.text('Receitas'));
    await tester.pumpAndSettle();
    expect(find.text('Panqueca de banana com aveia'), findsOneWidget);

    await tester.tap(find.text('Diário'));
    await tester.pumpAndSettle();
    expect(find.text('Nada registrado neste dia ainda.'), findsOneWidget);

    await tester.tap(find.text('Registrar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'arroz');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arroz, tipo 1, cozido'));
    await tester.pumpAndSettle();

    // Medida padrão do arroz: 1 colher de sopa (25 g) = 32 kcal.
    expect(find.text('32 kcal'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump();
    expect(find.text('64 kcal'), findsOneWidget); // 2 colheres = 50 g

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('2 colher de sopa · 50 g'), findsOneWidget);

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(find.text('Falar com a nutri'), findsOneWidget);
  });
}
