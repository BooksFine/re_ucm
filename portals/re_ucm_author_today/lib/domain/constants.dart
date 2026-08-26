import 'package:crypto/crypto.dart';

const userAgentAT = "okhttp/4.12.0 X_AT_API";
const xATClient = "android_1.8.013-GMS";
const xATCertificate = "rmy8LDkVZR+pSXopxUte7hFbA6I=";

final xATCertificateHashed = sha1
    .convert(xATCertificate.codeUnits)
    .toString()
    .toUpperCase();

const codeAT = 'AT';
const nameAT = 'AuthorToday';
const urlAT = 'https://author.today';
