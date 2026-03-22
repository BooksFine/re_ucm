enum SaveFormat {
  fb2Zip('.fb2.zip', 'application/zip'),
  epub('.epub', 'application/epub+zip'),
  fb2('.fb2', 'application/x-fictionbook+xml');

  final String ext;
  final String mimeType;

  const SaveFormat(this.ext, this.mimeType);

  String toJson() => name;

  static SaveFormat fromJson(String value) => SaveFormat.values.firstWhere(
    (e) => e.name == value,
    orElse: () => throw ArgumentError('Unknown SaveFormat: $value'),
  );
}
