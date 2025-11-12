bool isPersianText(String value) {
  return RegExp(r'[اآءؤئپچژکگ‌ی]').hasMatch(value);
}

String normalizeCityText(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('ي', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll(RegExp(r'\s+'), ' ');
}

String buildCityLabel(Map<String, dynamic> city) {
  final name = (city['local_names']?['fa'] ?? city['name'] ?? '').toString();
  final country = (city['country'] ?? '').toString();
  final state = (city['state'] ?? '').toString();

  return [
    name,
    if (state.isNotEmpty) state,
    if (country.isNotEmpty) country,
  ].join(', ');
}

int scoreCityCandidate(Map<String, dynamic> city, String query) {
  int score = 0;
  final country = (city['country'] ?? '').toString();
  final localName = (city['local_names']?['fa'] ?? '').toString();
  final name = (city['name'] ?? '').toString();
  final population = (city['population'] ?? 0) as int? ?? 0;
  final normalizedQuery = normalizeCityText(query);

  if (isPersianText(query) && country == 'IR') {
    score += 5;
  }
  if (normalizeCityText(localName) == normalizedQuery ||
      normalizeCityText(name) == normalizedQuery) {
    score += 4;
  }
  if (country == 'IR') {
    score += 2;
  }
  score += (population ~/ 100000);

  return score;
}

List<Map<String, dynamic>> sortAndDeduplicateCities(
  List<Map<String, dynamic>> cities,
  String query, {
  int maxItems = 10,
}) {
  if (cities.isEmpty) return const [];

  cities.sort(
    (a, b) => scoreCityCandidate(b, query) - scoreCityCandidate(a, query),
  );

  final seen = <String>{};
  final result = <Map<String, dynamic>>[];

  for (final city in cities) {
    final key = [
      (city['local_names']?['fa'] ?? city['name'] ?? '').toString(),
      (city['state'] ?? '').toString(),
      (city['country'] ?? '').toString(),
    ].join('|');

    if (seen.add(key)) {
      result.add(city);
    }
    if (result.length >= maxItems) {
      break;
    }
  }

  return result;
}
