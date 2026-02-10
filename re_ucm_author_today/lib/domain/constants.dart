import 'package:crypto/crypto.dart';

const userAgentAT = "okhttp/4.12.0 X_AT_API";
const xATClient = "android_1.8.013-GMS";
const xATSertificate = "rmy8LDkVZR+pSXopxUte7hFbA6I=";

final xATSertificateHashed = sha1
    .convert(xATSertificate.codeUnits)
    .toString()
    .toUpperCase();

const codeAT = 'AT';
const nameAT = 'AuthorToday';
const urlAT = 'https://author.today';
