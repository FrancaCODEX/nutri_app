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
| `services/` | Regras de negócio e integrações com o aparelho: `NutritionCalculator`, `TextSearch`, `HouseholdMeasures`, `ReminderScheduler` (notificações), `PhotoService` (câmera/galeria) | `models/` |
| `data/` | Fontes de dados: `FoodRepository` (TACO em `assets/`), `LocalStorage` (shared_preferences), dados de exemplo | `models/` |
| `state/` | Estado da aplicação e operações (`AppState`) | `models/`, `data/` |
| `screens/` | Telas e widgets | `state/`, `services/`, `models/` |

## Gerenciamento de estado

O app usa apenas o Flutter SDK:

- `AppState extends ChangeNotifier` guarda os dados e expõe métodos (`addDiaryEntry`, `sendMessage`...).
- `AppStateScope extends InheritedNotifier` coloca o estado na árvore de widgets.
- Telas obtêm o estado com `AppStateScope.of(context)` e são reconstruídas a cada `notifyListeners()`.

Isso evita dependências externas na fase inicial. Se o app crescer, a migração
natural é para `provider` ou `riverpod`, mantendo a mesma separação de camadas.

## Login e papéis (v0.4)

```
main → Firebase.initializeApp → AuthGate
  sem usuário            → LoginScreen
  e-mail = config/clinic → NutriHomeScreen (usa CloudRepository direto, com streams)
  existe patients/{uid}  → AppState + FirestorePatientBackend → HomeShell
  outro                  → tela "Conta sem cadastro"
```

- `CloudRepository` (`data/cloud_repository.dart`) concentra o acesso ao Firestore.
- `PatientBackend` (`state/patient_backend.dart`) é a interface que o `AppState`
  usa quando o paciente está logado: assina os streams (cardápio, receitas,
  diário, água, mensagens) e envia as alterações. Nos testes é trocada por uma
  versão em memória (`test/cloud_sync_test.dart`).
- Sem backend (testes e modo local), o `AppState` continua salvando no aparelho.

## Inicialização

`main.dart` abre o armazenamento local e carrega a TACO em paralelo, cria o
`AppState` com as dependências (`LocalStorage`, `LocalReminderService`, lista de
alimentos) e reagenda os lembretes se estiverem ligados.

As dependências são passadas no construtor, o que permite usar versões falsas
nos testes (`test/helpers/fakes.dart`).

## Persistência local (v0.2)

| Dado | Chave no shared_preferences | Formato |
|------|-----------------------------|---------|
| Diário | `diary_v1` | lista JSON de `DiaryEntry` (com cópia do alimento) |
| Chat | `messages_v1` | lista JSON de `ChatMessage` |
| Favoritos | `favorite_recipes_v1` | lista de ids |
| Lembretes ligados | `meal_reminders_enabled_v1` | bool |
| Cardápio editado | `meal_plan_v1` | JSON de `MealPlan` (se ausente, usa o de exemplo) |
| Receitas da nutricionista | `custom_recipes_v1` | lista JSON de `Recipe` |
| Água | `water_ml_by_day_v1` | mapa `yyyy-MM-dd` → ml |

Fotos são copiadas para `<documentos do app>/chat_photos/` e `<documentos do app>/recipe_photos/`.

## Android

- `android/app/build.gradle.kts`: *desugaring* (exigido pelas notificações) e
  assinatura com `teste.keystore` para APKs de teste.
- `AndroidManifest.xml`: permissões de notificação e *receivers* que reagendam os
  lembretes após reiniciar o celular.

## Navegação

`HomeShell` tem uma `NavigationBar` com 5 abas (Hoje, Cardápio, Receitas, Diário, Chat)
dentro de um `IndexedStack`, que preserva o estado de cada aba. Telas de detalhe
usam `Navigator.push`.

## Evolução para o Firebase (fase 2)

1. Criar interfaces de repositório (`MealPlanRepository`, `DiaryRepository`, `ChatRepository`, `RecipeRepository`, `FoodRepository`).
2. Implementações em memória (as atuais) e Firebase.
3. `AppState` recebe os repositórios no construtor; as telas não mudam.
4. Chat e diário passam a usar *streams* do Firestore para atualização em tempo real.

## Testes

| Arquivo | O que cobre |
|---------|-------------|
| `nutrition_calculator_test.dart` | cálculo de porções e totais |
| `search_and_measures_test.dart` | carga da TACO, busca e medidas caseiras |
| `app_state_test.dart` | persistência, desfazer, favoritos, chat, lembretes, recentes |
| `plan_and_tracking_test.dart` | cardápio (JSON, ordem, próxima refeição, edição), receitas próprias, água, histórico semanal |
| `cloud_sync_test.dart` | sincronização com a nuvem, envio de alterações, aviso de mensagem nova, não lidas, troca de conta |
| `widget_test.dart` | navegação, água e registro de alimento com medida caseira |
