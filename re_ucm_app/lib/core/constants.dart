import 'package:flutter/services.dart';

const appVersion = '3.0.2';
const isAlphaFlavor = appFlavor == 'alpha';
const appName = isAlphaFlavor ? 'α ReUCM' : 'ReUCM';

const telegramUrl = 'https://t.me/UltimateCopyManager';
const githubUrl = 'https://github.com/BooksFine/re_ucm';

const otaVersionUrl =
    "https://api.github.com/repos/BooksFine/re_ucm/releases/latest";
const otaHost =
    "https://github.com/BooksFine/re_ucm/releases/latest/download/ReUCM_android.apk";
const windowsOTAHost =
    "https://github.com/BooksFine/re_ucm/releases/latest/download/ReUCM_windows.exe";

const releasesUrl = "https://github.com/BooksFine/re_ucm/releases";
