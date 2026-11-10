# Funcionalidades

Legenda: ✅ implementado · 🟡 parcial · ⏳ planejado

## 1. Cardápio digital

Tela: `lib/screens/meal_plan_screen.dart`

| Requisito | Status |
|-----------|--------|
| Exibir o cardápio entregue na consulta (data, meta de kcal, observações gerais) | ✅ |
| Listar refeições com horário e opção principal | ✅ |
| Exibir **opções alternativas** equivalentes para cada refeição | ✅ |
| Ligar opções às receitas ("Como fazer") | ✅ |
| Observações por refeição | ✅ |
| Histórico de cardápios anteriores | ⏳ |
| Nutricionista cria/edita cardápio pelo painel | ⏳ |

**Regra:** as alternativas são definidas pela nutricionista e devem ser
nutricionalmente equivalentes à opção principal. O paciente não edita o cardápio.

## 2. Receitas

Telas: `recipes_screen.dart`, `recipe_detail_screen.dart`

| Requisito | Status |
|-----------|--------|
| Lista com categorias: Doce, Salgado, Lanche, Bebida | ✅ |
| Busca por nome e tags | ✅ |
| Detalhe: ingredientes, preparo, kcal/porção, tempo, rendimento | ✅ |
| Foto da receita | 🟡 suportado no modelo; upload na fase 3 |
| Favoritar receitas | ⏳ |
| Publicação pela nutricionista | ⏳ |

**Regra:** somente a nutricionista publica receitas.

## 3. Diário alimentar

Telas: `diary_screen.dart`, `add_food_screen.dart` · Cálculo: `services/nutrition_calculator.dart`

| Requisito | Status |
|-----------|--------|
| Buscar alimento na Tabela TACO (ignora acentos) | ✅ |
| Informar quantidade em gramas e refeição | ✅ |
| Pré-visualizar kcal e macros antes de salvar | ✅ |
| Total do dia vs. meta do cardápio, com barra de progresso | ✅ |
| Agrupar por refeição | ✅ |
| Navegar entre dias | ✅ |
| Remover registro (arrastar para o lado) | ✅ |
| Medidas caseiras (colher, concha, unidade) | ⏳ |
| Nutricionista visualiza o diário do paciente | ⏳ |
| Persistência | ⏳ fase 2 |

**Cálculo:** para cada registro, `valor = valor_por_100g × gramas / 100`.
O total do dia é a soma dos registros.

## 4. Chat com a nutricionista

Tela: `chat_screen.dart`

| Requisito | Status |
|-----------|--------|
| Enviar e exibir mensagens de texto | 🟡 local, sem servidor |
| Enviar **fotos** (câmera ou galeria) | ⏳ fase 2 (image_picker + Storage) |
| **Notificação** push de nova mensagem | ⏳ fase 2 (Firebase Cloud Messaging) |
| Indicador de lida | ⏳ |
| Horário de atendimento configurável | ⏳ |

**Regra:** o chat é sempre entre um paciente e a nutricionista. Não há respostas automáticas.

## 5. Contas e acesso (fase 2)

- Login por e-mail/senha (Firebase Auth).
- Paciente entra por convite da nutricionista (sem cadastro aberto).
- Papéis: `patient` e `nutritionist`.

## 6. Painel da nutricionista (fase 3)

- Lista de pacientes e último acesso.
- Criação de cardápios a partir de modelos.
- Cadastro de receitas com foto.
- Caixa de entrada do chat com todos os pacientes.
- Visualização dos diários.
