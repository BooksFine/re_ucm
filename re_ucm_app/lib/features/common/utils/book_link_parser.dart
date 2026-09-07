import 'package:re_ucm_core/re_ucm_core.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import 'uri_from_url.dart';

/// Единственное место парсинга «сырая строка → (portal, bookId, uri)».
class ParsedBookLink {
  const ParsedBookLink({
    required this.portal,
    required this.bookId,
    required this.uri,
  });

  final Portal portal;
  final String bookId;
  final Uri uri;
}

/// Возвращает `null`, если ссылка не является валидной ссылкой на книгу.
ParsedBookLink? tryParseBookLink(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  try {
    final uri = uriFromUrl(text);
    final portal = PortalFactory.fromUrl(uri);
    final bookId = portal.service.getIdFromUrl(uri);
    if (bookId.isEmpty) return null;
    return ParsedBookLink(portal: portal, bookId: bookId, uri: uri);
  } catch (_) {
    return null;
  }
}
