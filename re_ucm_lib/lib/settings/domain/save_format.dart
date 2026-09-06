enum SaveFormat {
  fb2Zip('.fb2.zip', 'application/x-zip-compressed-fb2', 'fb2.zip'),
  epub('.epub', 'application/epub+zip', 'epub'),
  fb2('.fb2', 'application/x-fictionbook+xml', 'fb2');

  final String ext;
  final String mimeType;
  final String label;

  const SaveFormat(this.ext, this.mimeType, this.label);

  String toJson() => name;

  static SaveFormat fromJson(String value) {
    try {
      return SaveFormat.values.byName(value);
    } catch (_) {
      throw ArgumentError('Unknown SaveFormat: $value');
    }
  }
}
