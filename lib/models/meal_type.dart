enum MealType {
  breakfast('Café da manhã'),
  morningSnack('Lanche da manhã'),
  lunch('Almoço'),
  afternoonSnack('Lanche da tarde'),
  dinner('Jantar'),
  supper('Ceia');

  const MealType(this.label);

  final String label;
}
