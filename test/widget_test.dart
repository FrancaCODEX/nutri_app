import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nutri_app/app.dart';
import 'package:nutri_app/state/app_state.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('abre no cardápio e navega pelas abas', (tester) async {
    await tester.pumpWidget(AppStateScope(state: AppState(), child: const NutriApp()));
    expect(find.text('Meu cardápio'), findsOneWidget);

    await tester.tap(find.text('Receitas'));
    await tester.pumpAndSettle();
    expect(find.text('Panqueca de banana com aveia'), findsOneWidget);

    await tester.tap(find.text('Diário'));
    await tester.pumpAndSettle();
    expect(find.text('Nada registrado neste dia ainda.'), findsOneWidget);

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(find.text('Falar com a nutri'), findsOneWidget);
  });
}
