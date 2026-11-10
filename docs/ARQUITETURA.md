# Arquitetura

## Visão geral

```
┌─────────────┐   lê / chama    ┌──────────────┐   usa    ┌──────────────────────┐
│   screens/  │ ──────────────▶ │   state/     │ ───────▶ │ services/  models/   │
│  (widgets)  │ ◀────────────── │  AppState    │          │ (regras e entidades) │
└─────────────┘  notifyListeners└──────┬───────┘          └──────────────────────┘
                                       │ fase 1: data/ (memória)
                                       │ fase 2: repositórios Firebase
                                       ▼
                                ┌──────────────┐
                                │  data source │
                                └──────────────┘
```

## Camadas

| Pasta | Responsabilidade | Depende de |
|-------|------------------|------------|
| `models/` | Entidades imutáveis, sem lógica de UI | nada |
| `services/` | Regras de negócio puras (ex.: `NutritionCalculator`) | `models/` |
| `data/` | Fontes de dados (hoje, dados de exemplo e amostra da TACO) | `models/` |
| `state/` | Estado da aplicação e operações (`AppState`) | `models/`, `data/` |
| `screens/` | Telas e widgets | `state/`, `services/`, `models/` |

## Gerenciamento de estado

O app usa apenas o Flutter SDK:

- `AppState extends ChangeNotifier` guarda os dados e expõe métodos (`addDiaryEntry`, `sendMessage`...).
- `AppStateScope extends InheritedNotifier` coloca o estado na árvore de widgets.
- Telas obtêm o estado com `AppStateScope.of(context)` e são reconstruídas a cada `notifyListeners()`.

Isso evita dependências externas na fase inicial. Se o app crescer, a migração
natural é para `provider` ou `riverpod`, mantendo a mesma separação de camadas.

## Navegação

`HomeShell` tem uma `NavigationBar` com 4 abas (Cardápio, Receitas, Diário, Chat)
dentro de um `IndexedStack`, que preserva o estado de cada aba. Telas de detalhe
usam `Navigator.push`.

## Evolução para o Firebase (fase 2)

1. Criar interfaces de repositório (`MealPlanRepository`, `DiaryRepository`, `ChatRepository`, `RecipeRepository`, `FoodRepository`).
2. Implementações em memória (as atuais) e Firebase.
3. `AppState` recebe os repositórios no construtor; as telas não mudam.
4. Chat e diário passam a usar *streams* do Firestore para atualização em tempo real.

## Testes

- Unitários para `services/` (ex.: `test/nutrition_calculator_test.dart`).
- Widget tests para telas críticas (a fazer).
