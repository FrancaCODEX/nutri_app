import '../models/food.dart';

/// Amostra da Tabela TACO (NEPA/UNICAMP, 4ª edição), valores por 100 g.
///
/// Esta lista é um ponto de partida. A tabela completa (~600 alimentos)
/// deve ser importada para o banco de dados - ver docs/TABELA_TACO.md.
const List<Food> tacoFoods = [
  Food(id: 'taco_arroz_branco_cozido', name: 'Arroz, tipo 1, cozido', category: 'Cereais', kcalPer100g: 128, proteinPer100g: 2.5, carbsPer100g: 28.1, fatPer100g: 0.2),
  Food(id: 'taco_arroz_integral_cozido', name: 'Arroz, integral, cozido', category: 'Cereais', kcalPer100g: 124, proteinPer100g: 2.6, carbsPer100g: 25.8, fatPer100g: 1.0),
  Food(id: 'taco_aveia_flocos', name: 'Aveia, flocos, crua', category: 'Cereais', kcalPer100g: 394, proteinPer100g: 13.9, carbsPer100g: 66.6, fatPer100g: 8.5),
  Food(id: 'taco_pao_frances', name: 'Pão, trigo, francês', category: 'Cereais', kcalPer100g: 300, proteinPer100g: 8.0, carbsPer100g: 58.6, fatPer100g: 3.1),
  Food(id: 'taco_pao_integral', name: 'Pão, trigo, forma, integral', category: 'Cereais', kcalPer100g: 253, proteinPer100g: 9.4, carbsPer100g: 49.9, fatPer100g: 3.7),
  Food(id: 'taco_feijao_carioca_cozido', name: 'Feijão, carioca, cozido', category: 'Leguminosas', kcalPer100g: 76, proteinPer100g: 4.8, carbsPer100g: 13.6, fatPer100g: 0.5),
  Food(id: 'taco_feijao_preto_cozido', name: 'Feijão, preto, cozido', category: 'Leguminosas', kcalPer100g: 77, proteinPer100g: 4.5, carbsPer100g: 14.0, fatPer100g: 0.5),
  Food(id: 'taco_frango_peito_grelhado', name: 'Frango, peito, sem pele, grelhado', category: 'Carnes', kcalPer100g: 159, proteinPer100g: 32.0, carbsPer100g: 0, fatPer100g: 2.5),
  Food(id: 'taco_patinho_grelhado', name: 'Carne, bovina, patinho, sem gordura, grelhado', category: 'Carnes', kcalPer100g: 219, proteinPer100g: 35.9, carbsPer100g: 0, fatPer100g: 7.3),
  Food(id: 'taco_ovo_cozido', name: 'Ovo, de galinha, inteiro, cozido', category: 'Ovos', kcalPer100g: 146, proteinPer100g: 13.3, carbsPer100g: 0.6, fatPer100g: 9.5),
  Food(id: 'taco_leite_integral', name: 'Leite, de vaca, integral', category: 'Leites', kcalPer100g: 61, proteinPer100g: 2.9, carbsPer100g: 4.3, fatPer100g: 3.5),
  Food(id: 'taco_iogurte_natural', name: 'Iogurte, natural', category: 'Leites', kcalPer100g: 51, proteinPer100g: 4.1, carbsPer100g: 1.9, fatPer100g: 3.0),
  Food(id: 'taco_queijo_minas_frescal', name: 'Queijo, minas, frescal', category: 'Leites', kcalPer100g: 264, proteinPer100g: 17.4, carbsPer100g: 3.2, fatPer100g: 20.2),
  Food(id: 'taco_banana_prata', name: 'Banana, prata, crua', category: 'Frutas', kcalPer100g: 98, proteinPer100g: 1.3, carbsPer100g: 26.0, fatPer100g: 0.1),
  Food(id: 'taco_maca_fuji', name: 'Maçã, Fuji, com casca, crua', category: 'Frutas', kcalPer100g: 56, proteinPer100g: 0.3, carbsPer100g: 15.2, fatPer100g: 0),
  Food(id: 'taco_mamao_papaia', name: 'Mamão, Papaia, cru', category: 'Frutas', kcalPer100g: 40, proteinPer100g: 0.5, carbsPer100g: 10.4, fatPer100g: 0.1),
  Food(id: 'taco_batata_doce_cozida', name: 'Batata, doce, cozida', category: 'Tubérculos', kcalPer100g: 77, proteinPer100g: 0.6, carbsPer100g: 18.4, fatPer100g: 0.1),
  Food(id: 'taco_brocolis_cozido', name: 'Brócolis, cozido', category: 'Hortaliças', kcalPer100g: 25, proteinPer100g: 2.1, carbsPer100g: 4.4, fatPer100g: 0.5),
  Food(id: 'taco_alface_crespa', name: 'Alface, crespa, crua', category: 'Hortaliças', kcalPer100g: 11, proteinPer100g: 1.3, carbsPer100g: 1.7, fatPer100g: 0.2),
  Food(id: 'taco_tomate', name: 'Tomate, com semente, cru', category: 'Hortaliças', kcalPer100g: 15, proteinPer100g: 1.1, carbsPer100g: 3.1, fatPer100g: 0.2),
  Food(id: 'taco_azeite', name: 'Azeite, de oliva, extra virgem', category: 'Óleos', kcalPer100g: 884, proteinPer100g: 0, carbsPer100g: 0, fatPer100g: 100),
];
