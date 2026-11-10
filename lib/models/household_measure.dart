/// Medida caseira com o peso aproximado em gramas (ex.: 1 concha = 140 g).
class HouseholdMeasure {
  const HouseholdMeasure(this.label, this.grams);

  /// Medida especial: o paciente informa os gramas diretamente.
  static const gramsUnit = HouseholdMeasure('gramas', 1);

  final String label;
  final double grams;

  bool get isGrams => identical(this, gramsUnit) || label == 'gramas';
}
