import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:re_ucm_lib/re_ucm_lib.dart';

/// Единый результат сохранения. Раньше возвращался `String?`,
/// где строка была то путём, то URI — теперь всегда [SavedFile].
class SavedFile {
  const SavedFile({required this.path, this.uri});

  final String path;
  final Uri? uri;
}

class BookSaver {
  /// Возвращает [SavedFile] или null при отмене диалога.
  Future<SavedFile?> saveToFile({
    required Uint8List bytes,
    required String templateFileName,
    required SaveFormat format,
    String? saveDirectory,
  }) async {
    final ext = format.ext;

    if (saveDirectory != null && saveDirectory.isNotEmpty) {
      final finalPath = p.join(saveDirectory, '$templateFileName$ext');
      final destFile = File(finalPath);
      await destFile.parent.create(recursive: true);
      await destFile.writeAsBytes(bytes);
      return SavedFile(path: finalPath);
    }

    final cleanExt = ext.startsWith('.') ? ext.substring(1) : ext;
    final savedUri = await FilePicker.saveFile(
      dialogTitle: 'Сохранение книги',
      bytes: bytes,
      fileName: '$templateFileName$ext',
      type: FileType.custom,
      allowedExtensions: [cleanExt],
    );
    if (savedUri != null) {
      final path = savedUri.isScheme('file')
          ? savedUri.toFilePath()
          : savedUri.toString();
      return SavedFile(path: path, uri: savedUri);
    }
    return null;
  }
}
