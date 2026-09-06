/// TODO: вернуть `String?` (null для неизвестного) — сейчас call-сайты
/// в portals/ ждут non-null строку, менять сигнатуру нельзя без их правок.
String guessMediaType(String path) {
  final lower = path.toLowerCase();
  const byExtension = {
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.gif': 'image/gif',
    '.webp': 'image/webp',
    '.svg': 'image/svg+xml',
  };
  for (final entry in byExtension.entries) {
    if (lower.endsWith(entry.key)) return entry.value;
  }
  return 'application/octet-stream';
}
