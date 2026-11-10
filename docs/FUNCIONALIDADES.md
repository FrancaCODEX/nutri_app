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
| Favoritar receitas e filtrar favoritas | ✅ v0.2 |
| Publicação pela nutricionista | ⏳ |

**Regra:** somente a nutricionista publica receitas.

## 3. Diário alimentar

Telas: `diary_screen.dart`, `add_food_screen.dart` · Cálculo: `services/nutrition_calculator.dart`

| Requisito | Status |
|-----------|--------|
| Buscar alimento na Tabela TACO completa (597 itens), ignorando acentos e ordem das palavras | ✅ v0.2 |
| Informar quantidade em gramas **ou medida caseira**, com botões + / − | ✅ v0.2 |
| Refeição sugerida pelo horário | ✅ v0.2 |
| Atalho de alimentos usados recentemente | ✅ v0.2 |
| Pré-visualizar kcal e macros antes de salvar | ✅ |
| Total do dia vs. meta do cardápio, com barra de progresso | ✅ |
| Agrupar por refeição | ✅ |
| Navegar entre dias | ✅ |
| Remover registro (arrastar para o lado), com opção de desfazer | ✅ v0.2 |

| Nutricionista visualiza o diário do paciente | ⏳ |
| Dados salvos no aparelho | ✅ v0.2 |
| Sincronização na nuvem | ⏳ v0.3 |

**Cálculo:** `gramas = quantidade × peso_da_medida`; para cada registro, `valor = valor_por_100g × gramas / 100`.
O total do dia é a soma dos registros.

## 4. Lembretes de refeição

Tela: `settings_screen.dart` · Serviço: `services/reminder_service.dart`

| Requisito | Status |
|-----------|--------|
| Ligar/desligar nas configurações | ✅ v0.2 |
| Notificação diária no horário de cada refeição do cardápio, com a opção principal | ✅ v0.2 |
| Pedir permissão de notificação (Android 13+) | ✅ v0.2 |
| Funciona sem internet e após reiniciar o celular | ✅ v0.2 |

## 5. Chat com a nutricionista

Tela: `chat_screen.dart`

| Requisito | Status |
|-----------|--------|
| Enviar e exibir mensagens de texto | 🟡 salvas no aparelho; entrega real na v0.3 |
| Enviar **fotos** (câmera ou galeria) e ver em tela cheia | ✅ v0.2 (local); upload na v0.3 |
| **Notificação** push de nova mensagem | ⏳ v0.3 (Firebase Cloud Messaging) |
| Indicador de lida | ⏳ |
| Horário de atendimento configurável | ⏳ |

**Regra:** o chat é sempre entre um paciente e a nutricionista. Não há respostas automáticas.

## 6. Contas e acesso (v0.3)

- Login por e-mail/senha (Firebase Auth).
- Paciente entra por convite da nutricionista (sem cadastro aberto).
- Papéis: `patient` e `nutritionist`.

## 7. Painel da nutricionista (v0.4)

- Lista de pacientes e último acesso.
- Criação de cardápios a partir de modelos.
- Cadastro de receitas com foto.
- Caixa de entrada do chat com todos os pacientes.
- Visualização dos diários.
