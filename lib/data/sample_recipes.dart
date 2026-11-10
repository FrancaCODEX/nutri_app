import '../models/recipe.dart';

/// Receitas de exemplo até a integração com o banco de dados.
const List<Recipe> sampleRecipes = [
  Recipe(
    id: 'r_panqueca_banana',
    title: 'Panqueca de banana com aveia',
    category: RecipeCategory.sweet,
    ingredients: ['1 banana prata madura', '1 ovo', '2 colheres (sopa) de aveia em flocos', 'Canela a gosto'],
    steps: [
      'Amasse a banana com um garfo.',
      'Misture o ovo, a aveia e a canela.',
      'Aqueça uma frigideira antiaderente e despeje a massa.',
      'Doure dos dois lados em fogo baixo.',
    ],
    kcalPerServing: 230,
    servings: 1,
    prepMinutes: 10,
    tags: ['café da manhã', 'sem açúcar'],
  ),
  Recipe(
    id: 'r_omelete_legumes',
    title: 'Omelete de legumes',
    category: RecipeCategory.savory,
    ingredients: ['2 ovos', '1/2 tomate picado', 'Brócolis cozido picado', 'Sal e orégano a gosto'],
    steps: [
      'Bata os ovos com sal e orégano.',
      'Junte o tomate e o brócolis.',
      'Cozinhe em frigideira untada com fio de azeite, tampada, em fogo baixo.',
    ],
    kcalPerServing: 200,
    servings: 1,
    prepMinutes: 15,
    tags: ['proteico', 'jantar'],
  ),
  Recipe(
    id: 'r_frango_batata_doce',
    title: 'Frango grelhado com batata-doce assada',
    category: RecipeCategory.savory,
    ingredients: ['120 g de peito de frango', '150 g de batata-doce', 'Alho, limão, ervas', '1 colher (chá) de azeite'],
    steps: [
      'Tempere o frango com alho, limão e ervas.',
      'Corte a batata-doce em rodelas e asse a 200 °C por 25 min.',
      'Grelhe o frango até dourar.',
    ],
    kcalPerServing: 350,
    servings: 1,
    prepMinutes: 35,
    tags: ['almoço', 'marmita'],
  ),
  Recipe(
    id: 'r_iogurte_frutas',
    title: 'Iogurte com frutas e aveia',
    category: RecipeCategory.snack,
    ingredients: ['1 pote de iogurte natural', '1/2 maçã picada', '1 colher (sopa) de aveia'],
    steps: ['Monte em camadas num copo e sirva gelado.'],
    kcalPerServing: 160,
    servings: 1,
    prepMinutes: 5,
    tags: ['lanche'],
  ),
];
