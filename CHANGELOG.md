# Changelog

## [0.4.0] - 2026-11-12

### Adicionado
- **Firebase** (Authentication + Firestore, projeto `nutri-app-42226`).
- **Login** com e-mail e senha, recuperação de senha e troca de senha.
- **Primeiro acesso da nutricionista** com confirmação de e-mail; o e-mail dela fica
  em `config/clinic` no Firestore (fora do código).
- **App da nutricionista**:
  - aba Pacientes: busca, último acesso, aviso de mensagem não lida e
    **cadastro de paciente** com senha provisória e mensagem pronta para enviar;
  - por paciente: **chat**, **cardápio** (montar/editar) e **acompanhamento**
    (gráfico de 7 dias, dias com registro, água e o que foi comido hoje);
  - aba Receitas: publicar com foto para todos os pacientes; importar receitas de exemplo.
- **App do paciente conectado**: cardápio, receitas, diário, água e chat sincronizados.
- **Chat em tempo real** com fotos (comprimidas e gravadas no Firestore, sem precisar do Storage).
- Notificação de mensagem nova da nutricionista com o app aberto ou em segundo plano.
- Regras de segurança em `firebase/firestore.rules`.

### Alterado
- A antiga "Área da nutricionista" local foi substituída pelo app da nutricionista com login.
- Se outra conta entrar no mesmo aparelho, os dados locais da anterior são apagados.

## [0.3.0] - 2026-11-11

### Adicionado
- **Nova logo**: maçã minimalista em verde, com versão para fundo claro (`assets/icon/logo_mark.png`).
- **Aba "Hoje"** (tela inicial): calorias do dia com anel de progresso, macronutrientes,
  controle de **água** (+/− copo de 250 ml) com meta, **próxima refeição** e
  **gráfico dos últimos 7 dias** com linha de meta.
- **Área da nutricionista** (Configurações → Área da nutricionista):
  - editar o cardápio: paciente, metas de calorias e água, orientações, refeições,
    horários, opção principal, **alternativas** e receitas ligadas;
  - criar, editar e excluir **receitas com foto** (câmera ou galeria).
- Lembretes reagendados automaticamente quando o cardápio muda.
- Receitas com foto aparecem com miniatura na lista.

### Alterado
- Cardápio exibido sempre em ordem de horário; meta de água no cabeçalho.
- Navegação com cinco abas: Hoje, Cardápio, Receitas, Diário e Chat.

## [0.2.0] - 2026-11-10

### Adicionado
- **Dados salvos no celular**: diário, chat, favoritos e preferências não se perdem ao fechar o app.
- **Tabela TACO completa**: 597 alimentos (antes eram 21), empacotados no app e disponíveis sem internet.
- **Busca melhor**: ignora acentos e a ordem das palavras ("frango grelhado" encontra "Frango, peito, sem pele, grelhado").
- **Medidas caseiras**: registrar em colher de sopa, concha, unidade, fatia, copo etc., com o peso convertido automaticamente; botões de + e −.
- **Alimentos recentes** como atalho no registro.
- **Refeição sugerida** de acordo com o horário.
- **Desfazer** ao remover um item do diário.
- **Fotos no chat** pela câmera ou galeria, com visualização em tela cheia.
- **Lembretes de refeição**: notificação diária no horário de cada refeição do cardápio.
- **Receitas favoritas** com filtro.
- **Configurações**: lembretes, base de alimentos e versão.
- **Ícone** e nome "Nutri App"; novo tema visual.
- Projeto Android versionado, com chave fixa para APKs de teste.

## [0.1.0] - 2026-11-10

### Adicionado
- Estrutura inicial em Flutter.
- Cardápio digital com opções alternativas e links para receitas.
- Receitas com busca e filtro.
- Diário alimentar com amostra da TACO e cálculo de calorias/macros.
- Chat local (texto).
- Documentação e geração automática de APK pelo GitHub Actions.
