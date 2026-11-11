# Contribuindo

## Ambiente

- Flutter 3.47.9 (mesma versão fixada em `.github/workflows/build-apk.yml`)
- Rodar `flutter analyze` e `flutter test` antes de cada commit

## Branches

- `main`: versão estável
- `feature/<descricao>`: novas funcionalidades (ex.: `feature/chat-fotos`)
- `fix/<descricao>`: correções

## Commits

Mensagens em português, no imperativo, com prefixo:

| Prefixo | Uso |
|---------|-----|
| `feat:` | nova funcionalidade |
| `fix:` | correção |
| `docs:` | documentação |
| `refactor:` | refatoração sem mudar comportamento |
| `test:` | testes |
| `chore:` | configuração, dependências |

Exemplo: `feat: adiciona envio de fotos no chat`

## Código

- Seguir `analysis_options.yaml` (flutter_lints).
- Modelos imutáveis (`final` + construtor `const`).
- Regras de negócio em `services/`, nunca dentro de widgets.
- Textos da interface em português.
