# Roadmap

## v0.1: Protótipo navegável ✅

- Estrutura do projeto Flutter e documentação
- Cardápio digital com alternativas e links para receitas
- Receitas com busca e filtro
- Diário alimentar com cálculo de calorias/macros
- Chat local (texto)

## v0.2: Funciona de verdade no celular ✅

- Dados salvos no aparelho (diário, chat, favoritos, preferências)
- Tabela TACO completa (597 alimentos) e busca sem acentos
- Medidas caseiras no registro
- Fotos no chat (câmera/galeria)
- Lembretes de refeição (notificações locais)
- Receitas favoritas, configurações, ícone e tema

## v0.3: Acompanhamento e área da nutricionista ✅

- Logo definitiva (maçã minimalista)
- Aba "Hoje": calorias, água, próxima refeição e evolução semanal
- Área da nutricionista no aparelho: editar cardápio e criar receitas com foto

## v0.4: Paciente e nutricionista conectados (Firebase)

Pré-requisito: projeto Firebase do consultório (ver [FIREBASE.md](FIREBASE.md)).

- Login: nutricionista e pacientes (por convite)
- Cardápio, receitas, diário e água sincronizados no Firestore
- Chat em tempo real com **fotos** (Storage) e **notificação de nova mensagem** (FCM)
- Área da nutricionista vira acesso restrito por login, com lista de pacientes
- Consentimento LGPD

## v0.5: Painel completo da nutricionista

- Lista de pacientes com último acesso e adesão (dias com registro, água)
- Visualizar o diário e a evolução de cada paciente
- Modelos de cardápio reutilizáveis
- Caixa de entrada única do chat
- Versão web (Flutter Web) para usar no computador do consultório

## v1.0: Publicação

- Lista de compras a partir das receitas
- Lembrete de água
- Gráficos de peso e medidas
- Modo offline com sincronização
- Publicação na Play Store e App Store
