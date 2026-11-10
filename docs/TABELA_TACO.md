# Tabela TACO

A **Tabela Brasileira de Composição de Alimentos (TACO)**, 4ª edição revisada
e ampliada, foi elaborada pelo NEPA/UNICAMP e é de livre acesso. Ela traz
cerca de 600 alimentos consumidos no Brasil, com valores por 100 g da parte comestível.

## Estado atual

`lib/data/taco_foods.dart` contém uma **amostra de 21 alimentos** para
desenvolvimento e testes. Os campos usados são:

| Campo TACO | Campo no app |
|------------|--------------|
| Descrição do alimento | `name` |
| Grupo | `category` |
| Energia (kcal) | `kcalPer100g` |
| Proteína (g) | `proteinPer100g` |
| Carboidrato (g) | `carbsPer100g` |
| Lipídeos (g) | `fatPer100g` |

## Importação completa (fase 2)

1. Baixar a planilha oficial no site do NEPA/UNICAMP.
2. Converter para CSV com as colunas acima e um `id` estável (ex.: número do alimento na TACO).
3. Tratar valores especiais da tabela: `Tr` (traços) → `0`; `NA` / `*` → `0` (ou vazio, se o campo permitir).
4. Gerar o campo `nameSearch` (minúsculas, sem acentos) para a busca.
5. Importar para a coleção `foods` do Firestore com um script (Node.js ou Python com Admin SDK).
6. Opcional: manter cópia local no app para busca offline.

## Medidas caseiras (futuro)

A TACO trabalha em gramas. Para facilitar o registro, criar uma tabela própria de
medidas (`1 colher de sopa de arroz = 25 g`, `1 concha de feijão = 140 g`...)
validada pela nutricionista.

## Aviso

Os valores são médias de laboratório e servem como estimativa.
