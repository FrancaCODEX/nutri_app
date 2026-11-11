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

Telas: `lib/screens/auth/` · Serviço: `services/auth_service.dart`

| Requisito | Status |
|-----------|--------|
| Login por e-mail e senha | ✅ |
| Esqueci minha senha (link por e-mail) | ✅ |
| Alterar senha (Configurações / Conta) | ✅ |
| Primeiro acesso da nutricionista com confirmação de e-mail | ✅ |
| Paciente criado pela nutricionista com senha provisória | ✅ |
| Conta sem cadastro não acessa dados | ✅ |
| Sair da conta | ✅ |

## 7. App da nutricionista (v0.4)

Telas: `lib/screens/nutri/`

| Requisito | Status |
|-----------|--------|
| Lista de pacientes com busca, último acesso e não lidas primeiro | ✅ |
| Contador de conversas não lidas na aba | ✅ |
| Cadastro de paciente + mensagem pronta com acesso (copiar) | ✅ |
| Chat com o paciente (texto e foto) | ✅ |
| Montar/editar o cardápio do paciente (alternativas, receitas ligadas, metas) | ✅ |
| Acompanhamento: kcal dos 7 dias, dias com registro, água, o que comeu hoje | ✅ |
| Publicar, editar e excluir receitas com foto | ✅ |
| Importar receitas de exemplo | ✅ |
| Notificação de mensagem nova com o app fechado | ⏳ plano Blaze |
