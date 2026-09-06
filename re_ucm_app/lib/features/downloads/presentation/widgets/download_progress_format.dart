import '../../../../core/ui/formatters.dart';

/// Единая формула «принято / всего (процент)» для прогресса картинок.
/// Раньше строка `formatBytes(received) / formatBytes(total)` была
/// скопирована в `download_progress_card` (и дрейфовала от `ota`).
String formatProgressBytes(int receivedBytes, int? totalBytes) {
  if (totalBytes == null || totalBytes <= 0) {
    return formatBytes(receivedBytes);
  }
  final progress = (receivedBytes / totalBytes).clamp(0.0, 1.0);
  final percent = (progress * 100).toInt();
  return '${formatBytes(receivedBytes)} / ${formatBytes(totalBytes)} ($percent%)';
}
