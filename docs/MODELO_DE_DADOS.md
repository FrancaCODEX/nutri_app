# Modelo de dados

## Entidades (Dart)

| Classe | Arquivo | Descrição |
|--------|---------|-----------|
| `Food` | `models/food.dart` | Alimento da TACO; valores por 100 g |
| `Nutrients` | `models/nutrients.dart` | kcal, proteína, carboidrato e gordura (somável) |
| `MealType` | `models/meal_type.dart` | Café da manhã, lanches, almoço, jantar, ceia |
| `HouseholdMeasure` | `models/household_measure.dart` | Medida caseira e peso em gramas |
| `DiaryEntry` | `models/diary_entry.dart` | Alimento + gramas + refeição + data (+ medida caseira) |
| `Recipe` / `RecipeCategory` | `models/recipe.dart` | Receita e categoria |
| `MealPlan` / `PlannedMeal` / `MealOption` | `models/meal_plan.dart` | Cardápio, refeições, opção principal e alternativas, metas de kcal e água |
| `ChatMessage` / `MessageAuthor` | `models/chat_message.dart` | Mensagem de texto e/ou foto (`imagePath` = data URI) |
| `PatientProfile` | `models/patient_profile.dart` | Cadastro do paciente visto pela nutricionista |

## Firestore (v0.4)

```
config/clinic
  nutritionistEmail: string            # cadastrado manualmente no console

recipes/{recipeId}
  title, category, ingredients[], steps[], kcalPerServing,
  servings, prepMinutes, imageUrl (data URI), tags[], isCustom

patients/{uid}                         # uid = usuário do Firebase Auth
  name, email, createdAt
  mealPlan: { patientName, nutritionistName, createdAt, kcalTarget,
              waterTargetMl, generalNotes,
              meals: [{ type, time, notes,
                        main: {description, recipeIds[]},
                        alternatives: [{description, recipeIds[]}] }] }
  lastSeenAt, lastPatientMessageAt, nutriReadAt

patients/{uid}/diary/{entryId}
  day ("yyyy-MM-dd"), date, meal, grams, portionLabel,
  food: { id, name, category, kcal, protein, carbs, fat, fiber }
  # cópia do alimento: o histórico não muda se a base mudar

patients/{uid}/water/{yyyy-MM-dd}
  ml, updatedAt

patients/{uid}/messages/{messageId}
  author ("patient" | "nutritionist"), text, imagePath, sentAt (Timestamp)
```

### Decisões

- **O cardápio fica dentro do cadastro do paciente**: um único cardápio ativo, lido
  em uma só leitura. Histórico de cardápios fica para depois.
- **Diário e água limitados aos últimos 60 dias** no app do paciente (14 dias na
  tela de acompanhamento da nutricionista), para economizar leituras.
- **"Não lida"** = `lastPatientMessageAt > nutriReadAt`.
- **Um chat por paciente**, já que o consultório tem uma nutricionista.

## Armazenamento local (shared_preferences)

| Dado | Chave |
|------|-------|
| Dono dos dados no aparelho | `owner_uid_v1` (outra conta entrando apaga o resto) |
| Favoritos | `favorite_recipes_v1` |
| Lembretes ligados | `meal_reminders_enabled_v1` |
| Modo sem login (testes): diário, chat, cardápio, receitas, água | `diary_v1`, `messages_v1`, `meal_plan_v1`, `custom_recipes_v1`, `water_ml_by_day_v1` |
