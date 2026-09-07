String formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
}

/// Единая формула «принято / всего (процент)» для прогресса байт/картинок.
String formatProgressBytes(int receivedBytes, int? totalBytes) {
  if (totalBytes == null || totalBytes <= 0) {
    return formatBytes(receivedBytes);
  }
  final progress = (receivedBytes / totalBytes).clamp(0.0, 1.0);
  final percent = (progress * 100).toInt();
  return '${formatBytes(receivedBytes)} / ${formatBytes(totalBytes)} ($percent%)';
}
