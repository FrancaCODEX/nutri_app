/// Chave de dia no formato "yyyy-MM-dd" (usada no diário, água e Firestore).
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
