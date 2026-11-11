# Funcionalidades

Legenda: ✅ implementado · 🟡 parcial · ⏳ planejado

## 0. Hoje (tela inicial)

Tela: `lib/screens/today_screen.dart`

| Requisito | Status |
|-----------|--------|
| Saudação e data | ✅ v0.3 |
| Calorias do dia com anel de progresso, quanto falta/excedeu e macros | ✅ v0.3 |
| Água: +/− copo de 250 ml, barra de progresso e meta definida no cardápio | ✅ v0.3 |
| Próxima refeição do cardápio (com nº de alternativas), abre a aba Cardápio | ✅ v0.3 |
| Gráfico dos últimos 7 dias com linha de meta (barra destacada acima de 110% da meta) | ✅ v0.3 |

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
| Refeições em ordem de horário | ✅ v0.3 |
| Nutricionista edita o cardápio | 🟡 v0.3 no aparelho (ver seção 8) |

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
| Publicação pela nutricionista, com foto | 🟡 v0.3 no aparelho (ver seção 8) |

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
| Sincronização na nuvem | ⏳ v0.4 |

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
| Enviar e exibir mensagens de texto | 🟡 salvas no aparelho; entrega real na v0.4 |
| Enviar **fotos** (câmera ou galeria) e ver em tela cheia | ✅ v0.2 (local); upload na v0.4 |
| **Notificação** push de nova mensagem | ⏳ v0.4 (Firebase Cloud Messaging) |
| Indicador de lida | ⏳ |
| Horário de atendimento configurável | ⏳ |

**Regra:** o chat é sempre entre um paciente e a nutricionista. Não há respostas automáticas.

## 6. Contas e acesso (v0.4)

- Login por e-mail/senha (Firebase Auth).
- Paciente entra por convite da nutricionista (sem cadastro aberto).
- Papéis: `patient` e `nutritionist`.

## 7. Painel da nutricionista (v0.5)

- Lista de pacientes e último acesso.
- Criação de cardápios a partir de modelos.
- Cadastro de receitas com foto.
- Caixa de entrada do chat com todos os pacientes.
- Visualização dos diários.

## 8. Área da nutricionista no aparelho (v0.3)

Telas: `lib/screens/nutri/` · Acesso: Configurações → Área da nutricionista

| Requisito | Status |
|-----------|--------|
| Editar paciente, nutricionista, meta de kcal, meta de água e orientações | ✅ v0.3 |
| Adicionar, editar e remover refeições (tipo, horário, observação) | ✅ v0.3 |
| Opção principal e alternativas, cada uma com receitas ligadas | ✅ v0.3 |
| Aviso ao sair com alterações não salvas | ✅ v0.3 |
| Criar, editar e excluir receitas com foto (câmera/galeria), ingredientes e preparo um por linha, tags | ✅ v0.3 |
| Lembretes reagendados ao salvar o cardápio | ✅ v0.3 |
| Acesso restrito por login | ⏳ v0.4 |

**Regra:** nesta versão a área não tem senha, porque o app ainda roda em um único
aparelho. Ela serve para a nutricionista montar o cardápio e as receitas e testar
como o paciente verá. Na v0.4 o acesso passa a depender do login de nutricionista.
