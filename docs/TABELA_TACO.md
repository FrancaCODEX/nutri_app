# Tabela TACO

A **Tabela Brasileira de Composição de Alimentos (TACO)**, 4ª edição revisada
e ampliada, foi elaborada pelo NEPA/UNICAMP e é de livre acesso. Ela traz
cerca de 600 alimentos consumidos no Brasil, com valores por 100 g da parte comestível.

## Estado atual

A tabela completa (**597 alimentos**) fica em `assets/data/taco.json`, empacotada
no app e carregada na abertura por `lib/data/food_repository.dart`. Funciona sem internet.

Os campos usados são:

| Campo TACO | Campo no app |
|------------|--------------|
| Descrição do alimento | `name` |
| Grupo | `category` |
| Energia (kcal) | `kcalPer100g` |
| Proteína (g) | `proteinPer100g` |
| Carboidrato (g) | `carbsPer100g` |
| Lipídeos (g) | `fatPer100g` |
| Fibra alimentar (g) | `fiberPer100g` |

## Como regenerar o arquivo

Os CSVs usados vêm do projeto aberto [taco-api](https://github.com/raulfdm/taco-api)
(pasta `references/csv`), que reproduz a 4ª edição da TACO.

```bash
python3 tool/gerar_taco.py <pasta_com_food.csv_nutrients.csv_categories.csv>
```

O script trata os valores especiais da tabela (`Tr` = traços, `NA`, `*`, vazio) como `0`.
O `id` de cada alimento é `taco_<número do alimento na TACO>` e **não deve mudar**,
porque o diário guarda referências a ele.

## Medidas caseiras

A TACO trabalha em gramas. Para facilitar o registro, `lib/services/household_measures.dart`
sugere medidas por palavra-chave no nome do alimento (ex.: arroz → colher de sopa 25 g,
escumadeira 90 g; feijão → concha média 140 g; ovo → unidade 50 g) e, quando não há
regra, pelo grupo do alimento. A opção em gramas está sempre disponível.

> Os pesos são aproximados e **devem ser revisados pela nutricionista**.
> Para ajustar, basta editar a lista `_rules` nesse arquivo.

## Aviso

Os valores são médias de laboratório e servem como estimativa.
