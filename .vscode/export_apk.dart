import 'dart:io';
import 'package:path/path.dart' as p;

void main(List<String> args) {
  final flavor = _getArg(args, '--flavor');

  // 1. Read version from pubspec.yaml
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    stderr.writeln('Error: pubspec.yaml not found in ${Directory.current.path}');
    exit(1);
  }

  final pubspecContent = pubspecFile.readAsStringSync();
  final versionMatch =
      RegExp(r'^version:\s*([^\s#]+)', multiLine: true).firstMatch(pubspecContent);
  final version = versionMatch?.group(1) ?? 'unknown';

  // 2. Find source APK
  final flutterApkDir =
      Directory(p.join('build', 'app', 'outputs', 'flutter-apk'));
  if (!flutterApkDir.existsSync()) {
    stderr.writeln(
        'Error: Directory ${flutterApkDir.path} does not exist. Did you run flutter build apk?');
    exit(1);
  }

  final possibleNames = <String>[
    if (flavor != null) 'app-$flavor-arm64-v8a-release.apk',
    if (flavor != null) 'app-$flavor-arm64-v8a-debug.apk',
    'app-arm64-v8a-release.apk',
    'app-prod-arm64-v8a-release.apk',
    'app-arm64-v8a-debug.apk',
    'app-prod-arm64-v8a-debug.apk',
  ];

  File? sourceApk;
  for (final name in possibleNames) {
    final file = File(p.join(flutterApkDir.path, name));
    if (file.existsSync()) {
      sourceApk = file;
      break;
    }
  }

  if (sourceApk == null) {
    // Fallback: search for any arm64 apk in flutter-apk folder
    final apks = flutterApkDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('arm64-v8a') && f.path.endsWith('.apk'))
        .toList();

    if (apks.isNotEmpty) {
      sourceApk = apks.first;
    } else {
      stderr.writeln(
          'Error: Could not find arm64-v8a APK in ${flutterApkDir.path}');
      exit(1);
    }
  }

  // 3. Determine Desktop path
  final desktopPath = _getDesktopPath();
  if (desktopPath == null || !Directory(desktopPath).existsSync()) {
    stderr.writeln('Error: Could not determine Desktop path ($desktopPath)');
    exit(1);
  }

  // 4. Formulate output APK name: ReUCM_flavor[build].apk
  final buildNumber = version.contains('+') ? version.split('+').last : version;
  final flavorPart = (flavor != null && flavor.isNotEmpty) ? '_$flavor' : '';
  final targetFileName = 'ReUCM$flavorPart[$buildNumber].apk';
  final targetFile = File(p.join(desktopPath, targetFileName));

  sourceApk.copySync(targetFile.path);

  stdout.writeln('========================================');
  stdout.writeln('Successfully copied APK to Desktop:');
  stdout.writeln('  Source: ${sourceApk.path}');
  stdout.writeln('  Destination: ${targetFile.path}');
  stdout.writeln('========================================');
}

String? _getArg(List<String> args, String name) {
  final idx = args.indexOf(name);
  if (idx != -1 && idx + 1 < args.length) {
    return args[idx + 1];
  }
  for (final arg in args) {
    if (arg.startsWith('$name=')) {
      return arg.substring(name.length + 1);
    }
  }
  return null;
}

String? _getDesktopPath() {
  if (Platform.isWindows) {
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null) {
      final desktop = p.join(userProfile, 'Desktop');
      if (Directory(desktop).existsSync()) return desktop;
      final ruDesktop = p.join(userProfile, 'Рабочий стол');
      if (Directory(ruDesktop).existsSync()) return ruDesktop;
      final oneDriveDesktop = p.join(userProfile, 'OneDrive', 'Desktop');
      if (Directory(oneDriveDesktop).existsSync()) return oneDriveDesktop;
      final oneDriveRuDesktop =
          p.join(userProfile, 'OneDrive', 'Рабочий стол');
      if (Directory(oneDriveRuDesktop).existsSync()) return oneDriveRuDesktop;
      return desktop;
    }
  }
  final home = Platform.environment['HOME'];
  if (home != null) {
    return p.join(home, 'Desktop');
  }
  return null;
}
