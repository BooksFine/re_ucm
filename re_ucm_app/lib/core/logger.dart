import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

import 'package:path_provider/path_provider.dart';

late final Logger logger;

Future<File> _getLogFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = directory.path;
  final logDir = Directory(path.join(filePath, 'ReUCM'));

  if (!await logDir.exists()) {
    await logDir.create(recursive: true);
  }

  return File(path.join(logDir.path, 'session_log.txt'));
}

Future<void> loggerInit() async {
  final logFile = await _getLogFile();
  final fileOutput = FileOutput(file: logFile, overrideExisting: true);

  logger = Logger(
    level: Level.all,
    printer: PrettyPrinter(),
    output: MultiOutput([ConsoleOutput(), fileOutput]),
    filter: ProductionFilter(),
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e(
      "Flutter Error: ${details.exceptionAsString()}",
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.e("Platform Error: $error", error: error, stackTrace: stack);
    return true;
  };
}
