import '../models/food.dart';
import '../models/household_measure.dart';

/// Sugere medidas caseiras para um alimento.
///
/// Os pesos são aproximados (referências usuais de medidas caseiras) e devem
/// ser validados pela nutricionista - ver docs/TABELA_TACO.md.
class HouseholdMeasures {
  const HouseholdMeasures._();

  static const _rules = <(List<String>, List<HouseholdMeasure>)>[
    (['arroz'], [HouseholdMeasure('colher de sopa', 25), HouseholdMeasure('escumadeira', 90)]),
    (['feijão', 'lentilha', 'grão-de-bico', 'ervilha'], [HouseholdMeasure('concha média', 140), HouseholdMeasure('colher de sopa', 20)]),
    (['macarrão'], [HouseholdMeasure('pegador', 110), HouseholdMeasure('colher de sopa', 25)]),
    (['pão, trigo, francês', 'pão, francês'], [HouseholdMeasure('unidade', 50)]),
    (['pão', 'torrada'], [HouseholdMeasure('fatia', 25)]),
    (['ovo'], [HouseholdMeasure('unidade', 50)]),
    (['aveia', 'granola', 'farinha', 'farofa', 'tapioca'], [HouseholdMeasure('colher de sopa', 15)]),
    (['açúcar', 'mel', 'doce', 'geleia'], [HouseholdMeasure('colher de chá', 5), HouseholdMeasure('colher de sopa', 15)]),
    (['azeite', 'óleo', 'manteiga', 'margarina', 'maionese'], [HouseholdMeasure('colher de chá', 4), HouseholdMeasure('colher de sopa', 13)]),
    (['iogurte'], [HouseholdMeasure('pote', 170)]),
    (['queijo', 'presunto', 'mortadela', 'peito de peru'], [HouseholdMeasure('fatia', 20)]),
    (['requeijão', 'creme de leite', 'leite condensado'], [HouseholdMeasure('colher de sopa', 15)]),
    (['leite', 'suco', 'refrigerante', 'café', 'chá', 'bebida', 'vitamina', 'água de coco'], [HouseholdMeasure('copo (200 ml)', 200), HouseholdMeasure('xícara (240 ml)', 240)]),
    (['banana'], [HouseholdMeasure('unidade', 65)]),
    (['maçã', 'pera'], [HouseholdMeasure('unidade', 130)]),
    (['laranja', 'tangerina', 'mexerica'], [HouseholdMeasure('unidade', 150)]),
    (['mamão'], [HouseholdMeasure('fatia', 150)]),
    (['melancia', 'melão', 'abacaxi'], [HouseholdMeasure('fatia', 200)]),
    (['morango', 'uva'], [HouseholdMeasure('unidade', 10)]),
    (['batata', 'mandioca', 'aipim', 'inhame', 'cará'], [HouseholdMeasure('colher de servir', 60), HouseholdMeasure('unidade média', 130)]),
    (['frango', 'carne', 'boi', 'porco', 'peixe', 'tilápia', 'pescada', 'salmão', 'atum', 'sardinha', 'patinho', 'alcatra', 'filé', 'bife'], [HouseholdMeasure('filé/bife médio', 100), HouseholdMeasure('colher de sopa (moída/desfiada)', 25)]),
    (['castanha', 'amendoim', 'amêndoa', 'noz'], [HouseholdMeasure('unidade', 4), HouseholdMeasure('colher de sopa', 15)]),
    (['alface', 'rúcula', 'agrião', 'couve', 'espinafre', 'acelga', 'repolho'], [HouseholdMeasure('prato de sobremesa', 30), HouseholdMeasure('folha', 10)]),
  ];

  static const _byCategory = <String, List<HouseholdMeasure>>{
    'Frutas e derivados': [HouseholdMeasure('unidade média', 120)],
    'Verduras, hortaliças e derivados': [HouseholdMeasure('colher de sopa', 25)],
  };

  static String _normalize(String s) => s.toLowerCase();

  static List<HouseholdMeasure> forFood(Food food) {
    final name = _normalize(food.name);
    for (final (keywords, measures) in _rules) {
      if (keywords.any(name.contains)) {
        return [...measures, HouseholdMeasure.gramsUnit];
      }
    }
    final byCategory = _byCategory[food.category];
    return [...?byCategory, HouseholdMeasure.gramsUnit];
  }
}
