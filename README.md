# Nutri App

<img src="assets/icon/icon.png" alt="Nutri App" width="96">

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
| **Hoje** | Resumo do dia: calorias vs. meta, **água**, próxima refeição e **evolução dos últimos 7 dias** | ✅ v0.3 |
| **Cardápio** | Cardápio digital entregue na consulta, refeição por refeição, com **opções alternativas** equivalentes e link para as receitas | ✅ |
| **Lembretes** | Notificação no horário de cada refeição do cardápio | ✅ v0.2 |
| **Receitas** | Receitas doces, salgadas, lanches e bebidas, com busca, filtro e **favoritas** | ✅ (dados de exemplo) |
| **Diário alimentar** | Busca nos **597 alimentos da Tabela TACO**, porção em **medidas caseiras** ou gramas, cálculo automático de calorias e macronutrientes, dados **salvos no celular** | ✅ v0.2 |
| **Chat** | Conversa com a nutricionista, com **fotos** (câmera ou galeria) | 🟡 salvo só no aparelho; entrega real e notificação de resposta com o Firebase (v0.4) |
| **Área da nutricionista** | Editar o cardápio (refeições, horários, alternativas, metas) e criar receitas com foto | 🟡 v0.3 no aparelho; login e nuvem na v0.4 |

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
Os APKs de teste são assinados sempre com a mesma chave (`android/app/teste.keystore`),
então uma versão nova instala **por cima** da anterior sem perder os dados.

## Como rodar

Pré-requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.22 ou superior.

```bash
git clone https://github.com/FrancaCODEX/nutri_app.git
cd nutri_app

# (opcional) gerar a pasta iOS, que ainda não está no repositório
# flutter create . --org br.com.nutriapp --project-name nutri_app --platforms ios

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
├── data/                     # TACO, armazenamento local e dados de exemplo
├── services/                 # regras de negócio (cálculo, busca, medidas, lembretes, fotos)
├── state/                    # estado da aplicação (AppState)
├── widgets/                  # componentes reutilizáveis (imagem, gráfico semanal)
└── screens/                  # telas (nutri/ = área da nutricionista)
assets/
├── data/taco.json            # Tabela TACO completa (597 alimentos)
└── icon/                     # ícone do app
android/                      # projeto Android (assinatura de teste, notificações)
tool/gerar_taco.py            # gera assets/data/taco.json a partir dos CSVs da TACO
test/                         # testes automatizados
docs/                         # documentação completa
```

## Documentação

| Documento | Conteúdo |
|-----------|----------|
| [Visão do produto](docs/VISAO_DO_PRODUTO.md) | Problema, público, objetivos |
| [Identidade visual](docs/IDENTIDADE_VISUAL.md) | Logo, cores e regras de uso |
| [Funcionalidades](docs/FUNCIONALIDADES.md) | Requisitos e regras de cada área |
| [Arquitetura](docs/ARQUITETURA.md) | Camadas, estado, fluxo de dados |
| [Modelo de dados](docs/MODELO_DE_DADOS.md) | Entidades e coleções do Firestore |
| [Tabela TACO](docs/TABELA_TACO.md) | Origem dos dados e importação completa |
| [Firebase](docs/FIREBASE.md) | Configuração do backend, regras de segurança e notificações |
| [Roadmap](docs/ROADMAP.md) | Fases de desenvolvimento |
| [Contribuindo](docs/CONTRIBUINDO.md) | Padrões de código, branches e commits |
| [Changelog](CHANGELOG.md) | O que mudou em cada versão |

## Aviso

Os valores nutricionais são estimativas baseadas na TACO e não substituem a
orientação da nutricionista.
