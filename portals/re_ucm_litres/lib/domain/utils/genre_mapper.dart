import 'package:dart_book/dart_book.dart';

/// Сопоставляет жанры LitRes (по ID, названию или URL) с общепринятыми кодами [BookGenre].
BookGenre mapLitresGenre({int? id, String? name, String? url}) {
  final cleanName = name?.trim();
  final lowerName = cleanName?.toLowerCase() ?? '';

  // 1. Поиск по точному ID жанра
  if (id != null && _genreIdMap.containsKey(id)) {
    final entry = _genreIdMap[id]!;
    return BookGenre(
      code: entry.code,
      name: cleanName != null && cleanName.isNotEmpty
          ? _capitalize(cleanName)
          : entry.name,
    );
  }

  // 2. Поиск по ключевым словам в названии
  if (lowerName.isNotEmpty) {
    for (final pattern in _keywordMap.entries) {
      if (lowerName.contains(pattern.key)) {
        return BookGenre(code: pattern.value, name: _capitalize(cleanName!));
      }
    }
  }

  // 3. Извлечение slug из URL (например: /genre/popadancy-5082/ -> popadancy)
  String? urlSlug;
  if (url != null && url.isNotEmpty) {
    final uriPath = Uri.tryParse(url)?.path ?? url;
    final segments = uriPath.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isNotEmpty) {
      final last = segments.last;
      final match = RegExp(r'^([a-zA-Z0-9_\-]+?)(?:-\d+)?$').firstMatch(last);
      if (match != null) {
        urlSlug = match.group(1);
      }
    }
  }

  final finalCode = urlSlug != null && urlSlug.isNotEmpty
      ? urlSlug.replaceAll('-', '_')
      : (id != null ? 'litres_$id' : 'unknown');

  return BookGenre(
    code: finalCode,
    name: cleanName != null && cleanName.isNotEmpty
        ? _capitalize(cleanName)
        : finalCode,
  );
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

class _GenreEntry {
  final String code;
  final String name;

  const _GenreEntry(this.code, this.name);
}

final Map<int, _GenreEntry> _genreIdMap = {
  // Фантастика
  5004: const _GenreEntry('sf', 'Фантастика'),
  5071: const _GenreEntry('sf_history', 'Историческая фантастика'),
  5072: const _GenreEntry('sf_cyberpunk', 'Киберпанк'),
  5073: const _GenreEntry('sf', 'Научная фантастика'),
  5074: const _GenreEntry('sf_action', 'Боевая фантастика'),
  5075: const _GenreEntry('sf_heroic', 'Героическая фантастика'),
  5076: const _GenreEntry('sf_detective', 'Детективная фантастика'),
  5077: const _GenreEntry('sf_space', 'Космическая фантастика'),
  5078: const _GenreEntry('sf_social', 'Социальная фантастика'),
  5079: const _GenreEntry('sf_humor', 'Юмористическая фантастика'),
  5080: const _GenreEntry('sf', 'Зарубежная фантастика'),
  5082: const _GenreEntry('popadancy', 'Попаданцы'),
  5084: const _GenreEntry('sf_steampunk', 'Стимпанк'),
  5090: const _GenreEntry('love_sf', 'Любовно-фантастические романы'),

  // Фэнтези
  5018: const _GenreEntry('sf_fantasy', 'Фэнтези'),
  5218: const _GenreEntry('sf_fantasy', 'Зарубежное фэнтези'),
  5227: const _GenreEntry('historical_fantasy', 'Историческое фэнтези'),
  5228: const _GenreEntry('urban_fantasy', 'Городское фэнтези'),
  5229: const _GenreEntry('epic_fantasy', 'Эпическое фэнтези'),
  5230: const _GenreEntry('dark_fantasy', 'Темное фэнтези'),
  5231: const _GenreEntry('romantic_fantasy', 'Романтическое фэнтези'),
  5232: const _GenreEntry('child_tale', 'Сказочное фэнтези'),
  5233: const _GenreEntry('sf_humor', 'Юмористическое фэнтези'),
  5234: const _GenreEntry('sf_heroic', 'Героическое фэнтези'),
  5235: const _GenreEntry('fantasy_action', 'Боевое фэнтези'),
  6337: const _GenreEntry('detective_fantasy', 'Детективное фэнтези'),

  // Детективы и триллеры
  5022: const _GenreEntry('detective', 'Детективы'),
  5086: const _GenreEntry('det_classic', 'Классические детективы'),
  5088: const _GenreEntry('det_action', 'Боевики'),
  5089: const _GenreEntry('det_ironic', 'Иронические детективы'),
  5097: const _GenreEntry('det_historical', 'Исторические детективы'),
  5098: const _GenreEntry('det_espionage', 'Шпионские детективы'),
  5099: const _GenreEntry('det_crime', 'Криминальные детективы'),
  5100: const _GenreEntry('det_police', 'Полицейские детективы'),
  5101: const _GenreEntry('thriller', 'Триллеры'),
  5014: const _GenreEntry('det_action', 'Боевики, остросюжетная литература'),
  5206: const _GenreEntry('det_action', 'Зарубежные боевики'),

  // Ужасы и мистика
  5017: const _GenreEntry('horror', 'Ужасы / мистика'),

  // Любовные романы и эротика
  5005: const _GenreEntry('love', 'Любовные романы'),
  5087: const _GenreEntry('love_history', 'Исторические любовные романы'),
  5091: const _GenreEntry('love_contemporary', 'Современные любовные романы'),
  5093: const _GenreEntry('love_erotica', 'Эротические романы'),
  5029: const _GenreEntry('erotica', 'Эротика и секс'),

  // Проза и классика
  5015: const _GenreEntry('prose_contemporary', 'Современная проза'),
  5028: const _GenreEntry('prose_classic', 'Классическая литература'),
  5211: const _GenreEntry(
    'prose_contemporary',
    'Современная зарубежная литература',
  ),
  5214: const _GenreEntry('prose_classic', 'Зарубежная классика'),
  5209: const _GenreEntry('prose_history', 'Историческая литература'),
  5205: const _GenreEntry('prose_military', 'Книги о войне'),
  5215: const _GenreEntry('prose_classic', 'Зарубежная старинная литература'),
  201926: const _GenreEntry('prose_contemporary', 'Легкая проза'),
  201671: const _GenreEntry('prose_classic', 'Классика жанра'),

  // Приключения
  5006: const _GenreEntry('adventure', 'Приключения'),
  5092: const _GenreEntry('adv_maritime', 'Морские приключения'),
  5094: const _GenreEntry('adv_geo', 'Книги о путешествиях'),
  5095: const _GenreEntry('adv_history', 'Исторические приключения'),
  5096: const _GenreEntry('adv_western', 'Зарубежные приключения'),
  203025: const _GenreEntry(
    'adv_history',
    'Классика приключенческой литературы',
  ),

  // Детские книги
  5007: const _GenreEntry('children', 'Детские книги'),
  5110: const _GenreEntry('child_tale', 'Сказки'),
  5111: const _GenreEntry('child_prose', 'Детская проза'),
  5112: const _GenreEntry('child_sf', 'Детская фантастика'),
  5113: const _GenreEntry('child_det', 'Детские детективы'),
  5114: const _GenreEntry('child_adv', 'Детские приключения'),

  // Юмор
  5013: const _GenreEntry('humor', 'Юмористическая литература'),
  5202: const _GenreEntry('humor', 'Зарубежный юмор'),

  // Поэзия и драматургия
  5213: const _GenreEntry('poetry', 'Зарубежная поэзия'),
  201711: const _GenreEntry('poetry', 'Стихи, поэзия'),
  5212: const _GenreEntry('dramaturgy', 'Зарубежная драматургия'),
  201695: const _GenreEntry('dramaturgy', 'Пьесы, драматургия'),

  // Документальная литература и публицистика
  5169: const _GenreEntry('nonf_biography', 'Биографии и мемуары'),
  5170: const _GenreEntry('nonfiction', 'Документальная литература'),
  5171: const _GenreEntry('nonf_publicism', 'Зарубежная публицистика'),
  203080: const _GenreEntry('nonf_biography', 'Истории успеха и биографии'),

  // Наука, бизнес, психология
  5003: const _GenreEntry('sci_business', 'Бизнес-книги'),
  201599: const _GenreEntry('sci_history', 'История'),
  201631: const _GenreEntry('sci_psychology', 'Психология, мотивация'),
  203062: const _GenreEntry('sci_psychology', 'Психология'),
  5217: const _GenreEntry('science', 'Зарубежная образовательная литература'),
  6351: const _GenreEntry('science', 'Прочая образовательная литература'),
  6469: const _GenreEntry('sci_religion', 'Религиозная литература'),
  6474: const _GenreEntry('sci_esoteric', 'Эзотерическая литература'),

  // Комиксы, манга, новеллы
  274060: const _GenreEntry('comics', 'Комиксы и манга'),
  274063: const _GenreEntry('comics', 'Западные комиксы'),
  274066: const _GenreEntry('manga', 'Азиатские комиксы и манга'),
  275083: const _GenreEntry('webtoon', 'Вебтун'),
  276439: const _GenreEntry('asian_novel', 'Азиатские новеллы'),
  276442: const _GenreEntry('child_comics', 'Детские комиксы'),
  276448: const _GenreEntry('rumanga', 'Руманга и рукомиксы'),

  // Прочее
  5019: const _GenreEntry('fanfiction', 'Фанфик'),
  174918: const _GenreEntry('young_adult', 'Young Adult'),
};

final Map<String, String> _keywordMap = {
  // Фантастика и фэнтези
  'героическая фантастика': 'sf_heroic',
  'космическая фантастика': 'sf_space',
  'боевая фантастика': 'sf_action',
  'научная фантастика': 'sf',
  'социальная фантастика': 'sf_social',
  'историческая фантастика': 'sf_history',
  'юмористическая фантастика': 'sf_humor',
  'детективная фантастика': 'sf_detective',
  'киберпанк': 'sf_cyberpunk',
  'стимпанк': 'sf_steampunk',
  'постапокалипсис': 'sf_postapocalyptic',
  'литрпг': 'litrpg',
  'реалрпг': 'realrpg',
  'попаданц': 'popadancy',
  'бояръ-аниме': 'boyar_anime',
  'бояраниме': 'boyar_anime',
  'уся': 'wuxia',
  'сянься': 'wuxia',
  'городское фэнтези': 'urban_fantasy',
  'эпическое фэнтези': 'epic_fantasy',
  'темное фэнтези': 'dark_fantasy',
  'романтическое фэнтези': 'romantic_fantasy',
  'боевое фэнтези': 'fantasy_action',
  'героическое фэнтези': 'sf_heroic',
  'историческое фэнтези': 'historical_fantasy',
  'юмористическое фэнтези': 'sf_humor',
  'детективное фэнтези': 'detective_fantasy',
  'фэнтези': 'sf_fantasy',
  'фантастик': 'sf',

  // Детективы и триллеры
  'исторический детектив': 'det_historical',
  'шпионский детектив': 'det_espionage',
  'криминальный детектив': 'det_crime',
  'полицейский детектив': 'det_police',
  'иронический детектив': 'det_ironic',
  'крутой детектив': 'det_action',
  'триллер': 'thriller',
  'боевик': 'det_action',
  'детектив': 'detective',
  'ужас': 'horror',
  'мистик': 'horror',

  // Любовные романы
  'исторический любовный': 'love_history',
  'современный любовный': 'love_contemporary',
  'короткий любовный': 'love_short',
  'эротическ': 'love_erotica',
  'эротика': 'erotica',
  'любовн': 'love',

  // Проза
  'русская классика': 'prose_rus_classic',
  'советская классика': 'prose_su_classics',
  'классическ': 'prose_classic',
  'историческая проза': 'prose_history',
  'военная проза': 'prose_military',
  'современная проза': 'prose_contemporary',
  'проза': 'prose',

  // Приключения
  'морские приключения': 'adv_maritime',
  'исторические приключения': 'adv_history',
  'путешестви': 'adv_geo',
  'вестерн': 'adv_western',
  'приключен': 'adventure',

  // Дети
  'сказк': 'child_tale',
  'детск': 'children',

  // Прочее
  'поэзи': 'poetry',
  'стих': 'poetry',
  'пьес': 'dramaturgy',
  'драматурги': 'dramaturgy',
  'юмор': 'humor',
  'биографи': 'nonf_biography',
  'мемуар': 'nonf_biography',
  'публицистик': 'nonf_publicism',
  'документальн': 'nonfiction',
  'психолог': 'sci_psychology',
  'бизнес': 'sci_business',
  'истори': 'sci_history',
  'манга': 'manga',
  'комикс': 'comics',
  'вебтун': 'webtoon',
  'новелл': 'asian_novel',
  'фанфик': 'fanfiction',
};
