import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:share_plus/share_plus.dart';

class BookSharer {
  /// Принимает готовые [fileName]/[text] — строки строит presentation
  /// ([BookShareTextBuilder]), domain только шарит файл.
  Future<void> shareBook({
    required Uint8List bytes,
    required String fileName,
    required String text,
    required SaveFormat format,
  }) async {
    final ext = format.ext;
    final mimeType = format.mimeType;

    final tempDir = (await getTemporaryDirectory()).path;
    final filePath = p.join(tempDir, '$fileName$ext');
    final tempFile = File(filePath);
    await tempFile.writeAsBytes(bytes);

    final xfile = XFile(filePath, name: '$fileName$ext', mimeType: mimeType);

    await SharePlus.instance.share(
      ShareParams(files: [xfile], text: text, subject: fileName),
    );
  }
}
