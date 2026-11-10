# Nutri App

Aplicativo do consultório de nutrição para acompanhar o paciente **entre as consultas**.

## O problema

Na consulta, o paciente recebe um cardápio e uma explicação. Depois, em casa,
ele tenta seguir o plano e fica perdido: *"tenho que comer tal coisa, mas como vou
preparar isso?"*. Quando precisa tirar uma dúvida, cai em atendimento
automático no WhatsApp.

O Nutri App mantém o cardápio da consulta no celular do paciente, junto com receitas,
registro do que ele comeu e um canal direto com a nutricionista.

## Funcionalidades

| Área | O que faz | Status |
|------|-----------|--------|
| **Cardápio** | Cardápio digital entregue na consulta, refeição por refeição, com **opções alternativas** equivalentes e link para as receitas | ✅ v0.1 (dados de exemplo) |
| **Receitas** | Receitas doces, salgadas, lanches e bebidas, com busca, filtro, ingredientes, preparo e calorias | ✅ v0.1 (dados de exemplo) |
| **Diário alimentar** | Paciente escolhe o alimento numa lista da **Tabela TACO**, informa a quantidade em gramas e o app **calcula** calorias e macronutrientes do dia | ✅ v0.1 (amostra da TACO) |
| **Chat** | Conversa direta com a nutricionista, com **fotos** e **notificações** | 🟡 v0.1 só texto local; fotos e notificações na fase 2 |
| **Painel da nutricionista** | Cadastro de pacientes, cardápios e receitas; resposta ao chat | ⏳ fase 3 |

Detalhes de cada funcionalidade em [`docs/FUNCIONALIDADES.md`](docs/FUNCIONALIDADES.md).

## Tecnologias

- **[Flutter](https://flutter.dev) / Dart**: um único código para Android e iOS
- **Firebase** (fase 2): autenticação, Firestore, Storage (fotos) e Cloud Messaging (notificações)
- **Tabela TACO** (NEPA/UNICAMP): base de composição de alimentos

## Baixar APK de teste

A cada push na `main`, o GitHub Actions gera um APK Android
(`.github/workflows/build-apk.yml`). Para baixar:

- **Releases → "APK de teste" → `nutri_app-teste.apk`**, ou
- **Actions → "Gerar APK de teste" → execução mais recente → Artifacts**.

No celular, permita a instalação de apps de fontes desconhecidas para instalar o APK.

## Como rodar

Pré-requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.22 ou superior.

```bash
git clone https://github.com/FrancaCODEX/nutri_app.git
cd nutri_app

# gera as pastas de plataforma (android/, ios/, web/...) sem alterar lib/
flutter create . --org br.com.nutriapp --project-name nutri_app

flutter pub get
flutter run
```

Testes:

```bash
flutter test
```

## Estrutura do projeto

```
lib/
├── main.dart                 # ponto de entrada
├── app.dart                  # tema e MaterialApp
├── models/                   # entidades (Food, Recipe, MealPlan, DiaryEntry, ChatMessage...)
├── data/                     # dados de exemplo e amostra da TACO
├── services/                 # regras de negócio (cálculo nutricional)
├── state/                    # estado da aplicação (AppState)
└── screens/                  # telas
test/                         # testes automatizados
docs/                         # documentação completa
```

## Documentação

| Documento | Conteúdo |
|-----------|----------|
| [Visão do produto](docs/VISAO_DO_PRODUTO.md) | Problema, público, objetivos |
| [Funcionalidades](docs/FUNCIONALIDADES.md) | Requisitos e regras de cada área |
| [Arquitetura](docs/ARQUITETURA.md) | Camadas, estado, fluxo de dados |
| [Modelo de dados](docs/MODELO_DE_DADOS.md) | Entidades e coleções do Firestore |
| [Tabela TACO](docs/TABELA_TACO.md) | Origem dos dados e importação completa |
| [Firebase](docs/FIREBASE.md) | Configuração do backend, regras de segurança e notificações |
| [Roadmap](docs/ROADMAP.md) | Fases de desenvolvimento |
| [Contribuindo](docs/CONTRIBUINDO.md) | Padrões de código, branches e commits |

## Aviso

Os valores nutricionais são estimativas baseadas na TACO e não substituem a
orientação da nutricionista.
