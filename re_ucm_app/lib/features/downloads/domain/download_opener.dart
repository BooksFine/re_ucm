import 'package:open_file/open_file.dart';

/// Абстракция открытия файла для мока в тестах.
/// Раньше [DownloadTask.open] вызывал `OpenFile.open` напрямую.
abstract class DownloadOpener {
  Future<void> openFile(String path);
}

class DefaultDownloadOpener implements DownloadOpener {
  const DefaultDownloadOpener();

  @override
  Future<void> openFile(String path) => OpenFile.open(path);
}
