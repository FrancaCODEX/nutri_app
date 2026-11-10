/// Busca textual tolerante a acentos e à ordem das palavras.
///
/// "frango grelhado" encontra "Frango, peito, sem pele, grelhado".
/// Resultados que começam com o termo aparecem primeiro.
class TextSearch {
  const TextSearch._();

  static const _from = 'áàâãäéèêëíìîïóòôõöúùûüç';
  static const _to = 'aaaaaeeeeiiiiooooouuuuc';

  static String normalize(String s) {
    final buffer = StringBuffer();
    for (final rune in s.toLowerCase().runes) {
      final ch = String.fromCharCode(rune);
      final i = _from.indexOf(ch);
      buffer.write(i >= 0 ? _to[i] : ch);
    }
    return buffer.toString();
  }

  static List<T> rank<T>(
    List<T> items,
    String query,
    String Function(T) textOf, {
    int limit = 60,
  }) {
    final terms = normalize(query)
        .split(RegExp(r'[\s,]+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (terms.isEmpty) return items.take(limit).toList();

    final scored = <(int, T)>[];
    for (final item in items) {
      final text = normalize(textOf(item));
      if (!terms.every(text.contains)) continue;
      var score = 0;
      if (text.startsWith(terms.first)) score += 10;
      score -= text.length ~/ 20; // nomes mais curtos/genéricos primeiro
      scored.add((score, item));
    }
    scored.sort((a, b) => b.$1.compareTo(a.$1));
    return scored.take(limit).map((e) => e.$2).toList();
  }
}
