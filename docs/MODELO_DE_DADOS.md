# Modelo de dados

## Entidades (Dart)

| Classe | Arquivo | Descrição |
|--------|---------|-----------|
| `Food` | `models/food.dart` | Alimento da TACO; valores por 100 g |
| `Nutrients` | `models/nutrients.dart` | kcal, proteína, carboidrato e gordura (somável) |
| `MealType` | `models/meal_type.dart` | Café da manhã, lanche, almoço, lanche da tarde, jantar, ceia |
| `DiaryEntry` | `models/diary_entry.dart` | Alimento + gramas + refeição + data |
| `Recipe` / `RecipeCategory` | `models/recipe.dart` | Receita e categoria (doce, salgado, lanche, bebida) |
| `MealPlan` / `PlannedMeal` / `MealOption` | `models/meal_plan.dart` | Cardápio, refeições, opção principal e alternativas |
| `ChatMessage` / `MessageAuthor` | `models/chat_message.dart` | Mensagem de texto e/ou foto |

## Coleções no Firestore (fase 2)

```
users/{uid}
  name, email, role: "patient" | "nutritionist", createdAt, fcmTokens: [..]

foods/{foodId}                        # TACO, somente leitura
  name, category, kcal, protein, carbs, fat, nameSearch

recipes/{recipeId}
  title, category, ingredients[], steps[], kcalPerServing,
  servings, prepMinutes, imageUrl, tags[], createdAt

patients/{patientUid}/mealPlans/{planId}
  createdAt, kcalTarget, waterTargetMl, generalNotes, active: bool,
  meals: [{ type, time, notes, main: {description, recipeIds[]},
            alternatives: [{description, recipeIds[]}] }]

patients/{patientUid}/diary/{entryId}
  date (yyyy-MM-dd), meal, foodId, foodName, grams,
  kcal, protein, carbs, fat, createdAt
  # valores calculados são gravados para preservar o histórico

patients/{patientUid}/water/{yyyy-MM-dd}
  ml, updatedAt

chats/{patientUid}/messages/{messageId}
  author: "patient" | "nutritionist", text, imageUrl, sentAt, readAt
```

### Decisões

- **Diário guarda os valores calculados** além do `foodId`: se a base de alimentos mudar, o histórico não muda.
- **Um chat por paciente** (`chats/{patientUid}`), já que só existe uma nutricionista.
- **Cardápio ativo**: só um `mealPlan` com `active: true` por paciente; os demais formam o histórico.

## Storage

```
chat_images/{patientUid}/{messageId}.jpg
recipe_images/{recipeId}.jpg
```
