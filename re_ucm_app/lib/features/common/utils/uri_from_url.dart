Uri uriFromUrl(String url) {
  if (!url.startsWith(RegExp(r'https?://'))) {
    url = 'https://$url';
  }
  final uri = Uri.parse(url);
  return uri;
}
