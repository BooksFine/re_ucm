import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

import 'package:re_ucm_author_today/domain/constants.dart';

// import 'dart:typed_data';
// import 'package:encrypt/encrypt.dart';

String reverseString(String input) {
  // Используем руны для корректной работы с Unicode символами
  return String.fromCharCodes(input.runes.toList().reversed);
}

/// Генерирует ключ пользователя в соответствии с восстановленным алгоритмом.
///
/// [inputString] - Входная строка (соответствует param_5 в JNI).
/// [userId] - ID пользователя (соответствует param_4 в JNI).
///          Используйте -1 для получения строки "Guest".
/// [certHash] - Хеш сертификата приложения, ПОСЛЕ удаления символов '\n'.
String generateUserKey({
  required String inputString,
  required String? userId,
  required String certHash,
}) {
  // 1. Константы, извлеченные из библиотеки

  // Строка "Guest" (деобфусцированная из DAT_00149870)
  const String constUserIdStr = "Guest";

  const List<int> hardcodedBytes = [
    0x46, 0x6a, 0x50, 0x67, 0x5d, 0x7b, 0x32, 0x2b, // FjPg]{2+
    0x24, 0x38, 0x4a, 0x52, 0x76, 0x76, 0x7e, 0x28, // $8JRvv~(
  ];
  // Преобразуем байты в строку через Latin-1 (каждый байт в символ)
  final String hardcodedStr = latin1.decode(hardcodedBytes);

  // Строка ":" (из DAT_00114d17)
  const String colonSeparator = ":";

  // 2. Формирование "ключа приложения" (appKeyStr)
  // appKeyStr = hardcodedStr + ":" + certHash
  final String appKeyStr = '$hardcodedStr$colonSeparator$certHash';

  // 3. Обработка входной строки
  // combinedInputStr = Reverse(inputStr) + ":"
  final String reversedInputString = reverseString(inputString);
  final String combinedInputStr = '$reversedInputString$colonSeparator';

  // 4. Обработка ID пользователя
  final String userPart = userId ?? constUserIdStr;

  // 5. Формирование финального ключа
  // finalKeyMaterialStr = combinedInputStr + userPart + ":" + appKeyStr
  final String finalKeyMaterialStr =
      '$combinedInputStr$userPart$colonSeparator$appKeyStr';

  // 6. Возврат результата
  return finalKeyMaterialStr;
}

Future<String> decryptData(String text, String key, String? userId) async {
  String finalKey = generateUserKey(
    inputString: key,
    userId: userId,
    certHash: xATCertificate,
  );

  return decryptChapter(text, finalKey);
}

String decryptChapter(String text, String key) {
  // 2. MD5 от userKey, hex-строкой (32 символа)
  String hashedKey = md5.convert(utf8.encode(key)).toString().toUpperCase();

  // 3. Берём первые 16 байт от hex-строки (в оригинале hex, но в Java брали getBytes, т.е. ASCII-коды символов hex-строки)
  List<int> keyBytes = utf8.encode(hashedKey.substring(0, 16));
  // В оригинале IV = keyBytes
  final iv = keyBytes;

  // 4. Декодируем base64
  final encrypted = base64.decode(text);

  // 5. Расшифровываем AES/CBC/PKCS7Padding
  final cipher = PaddedBlockCipher('AES/CBC/PKCS7')
    ..init(
      false,
      PaddedBlockCipherParameters(
        ParametersWithIV(
          KeyParameter(Uint8List.fromList(keyBytes)),
          Uint8List.fromList(iv),
        ),
        null,
      ),
    );

  final decrypted = cipher.process(Uint8List.fromList(encrypted));
  return utf8.decode(decrypted);
}

//Старый алгоритм, для истории
// String decryptDataWrapper((String, String, String?) args) {
//   final (data, key, userId) = args;
//   return decryptData(data, key, userId);
// }

// String decryptData(String text, String key, String? userId) {
//   List<int> data = [];
//   String finalKey = '${key.split('').reversed.join('')}@_@${userId ?? ''}';

//   for (int i = 0; i < text.length; i++) {
//     data.add(text.codeUnitAt(i) ^ finalKey.codeUnitAt(i % finalKey.length));
//   }

//   return String.fromCharCodes(data);
// }
