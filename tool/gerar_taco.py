"""Gera assets/data/taco.json a partir dos CSVs da Tabela TACO (4ª edição).

Uso:
    python3 tool/gerar_taco.py <pasta_com_csvs>

A pasta deve conter food.csv, nutrients.csv e categories.csv
(formato do projeto aberto github.com/raulfdm/taco-api, pasta references/csv).
"""
import csv
import json
import sys
from pathlib import Path


def num(value):
    """Converte valores da TACO: vazio, 'NA', 'Tr' (traços) e '*' viram 0."""
    try:
        return round(float(value), 2)
    except (TypeError, ValueError):
        return 0


def main(src: Path, dest: Path):
    categories = {r["id"]: r["name"] for r in csv.DictReader(open(src / "categories.csv", encoding="utf-8"))}
    nutrients = {r["foodId"]: r for r in csv.DictReader(open(src / "nutrients.csv", encoding="utf-8"))}
    foods = []
    for row in csv.DictReader(open(src / "food.csv", encoding="utf-8")):
        n = nutrients.get(row["id"], {})
        foods.append({
            "id": f"taco_{row['id']}",
            "name": row["name"].strip(),
            "category": categories.get(row["categoryId"], "Outros"),
            "kcal": num(n.get("kcal")),
            "protein": num(n.get("protein")),
            "carbs": num(n.get("carbohydrates")),
            "fat": num(n.get("lipids")),
            "fiber": num(n.get("dietaryFiber")),
        })
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(json.dumps(foods, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(f"{len(foods)} alimentos gravados em {dest}")


if __name__ == "__main__":
    main(Path(sys.argv[1]), Path(__file__).resolve().parent.parent / "assets" / "data" / "taco.json")
