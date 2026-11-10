import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_app/data/food_repository.dart';
import 'package:nutri_app/models/food.dart';
import 'package:nutri_app/services/household_measures.dart';
import 'package:nutri_app/services/text_search.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Food> taco;
  setUpAll(() async => taco = await FoodRepository.loadTaco(rootBundle));

  List<String> search(String q) => TextSearch.rank(taco, q, (f) => f.name).map((f) => f.name).toList();

  test('TACO completa é carregada do asset', () {
    expect(taco.length, greaterThan(590));
    final rice = taco.firstWhere((f) => f.name == 'Arroz, tipo 1, cozido');
    expect(rice.kcalPer100g, 128);
    expect(rice.carbsPer100g, 28.1);
  });

  test('busca ignora acentos e ordem das palavras', () {
    expect(search('feijao carioca cozido'), contains('Feijão, carioca, cozido'));
    expect(search('frango grelhado').first, startsWith('Frango'));
    expect(search('MACA fuji'), anyElement(startsWith('Maçã, Fuji')));
    expect(search('xyzabc'), isEmpty);
  });

  test('medidas caseiras por tipo de alimento, sempre com opção em gramas', () {
    Food named(String name) => taco.firstWhere((f) => f.name == name);
    final rice = HouseholdMeasures.forFood(named('Arroz, tipo 1, cozido'));
    expect(rice.first.label, 'colher de sopa');
    expect(rice.last.isGrams, isTrue);

    final beans = HouseholdMeasures.forFood(named('Feijão, carioca, cozido'));
    expect(beans.first.label, 'concha média');

    final egg = HouseholdMeasures.forFood(taco.firstWhere((f) => f.name.startsWith('Ovo, de galinha, inteiro, cozido')));
    expect(egg.first.label, 'unidade');

    for (final f in taco) {
      final m = HouseholdMeasures.forFood(f);
      expect(m.last.isGrams, isTrue, reason: f.name);
      expect(m.every((x) => x.grams > 0), isTrue, reason: f.name);
    }
  });
}
