import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dart_book/dart_book.dart';
import '../constants.dart';

String generateLitresMd5(int timestamp, String artId) {
  final input = '$timestamp:$artId:$secretKeyLR';
  return md5.convert(ascii.encode(input)).toString().toLowerCase();
}

Uri buildDownloadUri({
  required String artId,
  required String path,
  required String sid,
  String? host,
  int? fileId,
  String? type,
}) {
  final ts = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  final hash = generateLitresMd5(ts, artId);
  final baseHost = host ?? 'catalit.litres.ru';
  final queryParams = <String, String>{
    'art': artId,
    'sid': sid,
    'uilang': 'ru',
    'libapp': appIdLR,
    'timestamp': ts.toString(),
    'md5': hash,
  };
  if (fileId != null) {
    queryParams['file'] = fileId.toString();
  }
  if (type != null && type.isNotEmpty) {
    queryParams['type'] = type;
  }
  return Uri.https(baseHost, '/pages/$path/', queryParams);
}

Future<Book> decodeBookBytes(Uint8List bytes) {
  return Isolate.run(() => _decodeComputation(bytes));
}

Future<Book> _decodeComputation(Uint8List bytes) async {
  final fb2Zip = Fb2ZipDecoder();
  if (fb2Zip.canDecode(bytes, extension: 'fb2.zip')) {
    try {
      return fb2Zip.decode(bytes);
    } catch (_) {}
  }

  final epub = EpubDecoder();
  if (epub.canDecode(bytes, extension: 'epub')) {
    try {
      return await epub.decode(bytes);
    } catch (_) {}
  }

  final fb2 = Fb2Decoder();
  if (fb2.canDecode(bytes, extension: 'fb2')) {
    try {
      return fb2.decode(bytes);
    } catch (_) {}
  }

  // Fallback: пробуем декодировать по очереди
  try {
    return fb2Zip.decode(bytes);
  } catch (_) {
    try {
      return await epub.decode(bytes);
    } catch (_) {
      return fb2.decode(bytes);
    }
  }
}
