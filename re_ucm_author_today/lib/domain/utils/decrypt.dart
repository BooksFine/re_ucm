String decryptDataWrapper((String, String, String?) args) {
  final (data, key, userId) = args;
  return decryptData(data, key, userId);
}

String decryptData(String text, String key, String? userId) {
  List<int> data = [];
  String finalKey = '${key.split('').reversed.join('')}@_@${userId ?? ''}';

  for (int i = 0; i < text.length; i++) {
    data.add(text.codeUnitAt(i) ^ finalKey.codeUnitAt(i % finalKey.length));
  }

  return String.fromCharCodes(data);
}
