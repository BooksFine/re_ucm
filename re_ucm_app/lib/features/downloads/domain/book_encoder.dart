import 'dart:typed_data';

import 'package:dart_book/dart_book.dart' show Book, BookEncodingOptions;
import 'package:re_ucm_core/re_ucm_core.dart' hide logger;
import 'package:re_ucm_lib/re_ucm_lib.dart';

class BookEncoder {
  Future<Uint8List> encode({
    required Book book,
    required SaveFormat format,
    BookEncodingOptions? options,
    void Function(Progress progress)? onProgress,
  }) {
    return BookExporter.encode(
      book: book,
      format: format,
      options: options,
      onProgress: onProgress,
    );
  }
}
