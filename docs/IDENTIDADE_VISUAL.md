# Identidade visual

## Logo

Uma **maçã** em traço único, sem detalhes, com uma folha. A ideia é comunicar
alimentação saudável de forma simples e reconhecível, mesmo no tamanho de um
ícone de celular.

| Arquivo | Uso |
|---------|-----|
| `assets/icon/icon.png` | Ícone completo (maçã branca sobre fundo verde arredondado) |
| `assets/icon/icon_foreground.png` | Camada da frente do ícone adaptativo do Android |
| `assets/icon/logo_mark.png` | Marca verde sobre fundo transparente, para uso dentro do app e em fundos claros |

Para regenerar os ícones do Android depois de trocar as imagens:

```bash
dart run flutter_launcher_icons
```

## Cores

| Nome | Hex | Uso |
|------|-----|-----|
| Verde principal | `#2E7D5B` | Fundo do ícone, cor-semente do tema (`NutriApp.brandColor`) |
| Verde folha | `#A5D6A7` / `#66BB6A` | Folha da logo |
| Branco | `#FFFFFF` | Maçã no ícone |
| Azul água | `Colors.blue.shade400` | Indicadores de hidratação |

O tema do app é gerado a partir do verde principal com Material 3
(`ColorScheme.fromSeed`). Para trocar a cor do app inteiro, altere apenas
`brandColor` em `lib/app.dart`.

## Regras de uso

- Manter a logo sempre com área livre ao redor (no mínimo 1/4 da largura).
- Não distorcer, girar ou aplicar sombras.
- Em fundos escuros, usar a versão com fundo verde (`icon.png`).
