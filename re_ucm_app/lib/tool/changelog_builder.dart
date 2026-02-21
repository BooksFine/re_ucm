import 'dart:async';
import 'package:build/build.dart';

class ChangelogBuilder implements Builder {
  @override
  final Map<String, List<String>> buildExtensions = const {
    'CHANGELOG.md': ['lib/.gen/features/changelog/changelog.gen.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputContent = await buildStep.readAsString(buildStep.inputId);
    final sections = inputContent
        .split('### ')
        .where((s) => s.trim().isNotEmpty);

    final buffer = StringBuffer();
    buffer.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
    buffer.writeln("import '../../../features/changelog/changelog.dart';\n");
    buffer.writeln("const changelogGen = [");

    for (final section in sections) {
      final lines = section.split('\n');
      final header = lines[0].trim().split(' - ');
      final version = header[0];
      final date = header.length > 1 ? header[1] : '';

      final rest = lines.sublist(1).join('\n').trim();

      String content = rest;
      String? technicalDetails;

      if (rest.contains('<details>')) {
        final detailsRegExp = RegExp(
          r'<details>\s*<summary>(.*?)</summary>\s*([\s\S]*?)\s*</details>',
          multiLine: true,
        );
        final match = detailsRegExp.firstMatch(rest);

        if (match != null) {
          technicalDetails = match.group(2)?.trim();
          content = rest.replaceFirst(match.group(0)!, '').trim();
        }
      }

      content = _formatBullets(content);
      technicalDetails = technicalDetails != null
          ? _formatBullets(technicalDetails)
          : null;

      buffer.writeln("  Changelog(");
      buffer.writeln("    title: 'Релиз $version',");
      buffer.writeln("    date: '$date',");
      buffer.writeln("    content: r'''$content''',");
      if (technicalDetails != null) {
        buffer.writeln("    technicalDetails: r'''$technicalDetails''',");
      }
      buffer.writeln("  ),");
    }

    buffer.writeln("];");

    final outputId = AssetId(
      buildStep.inputId.package,
      'lib/.gen/features/changelog/changelog.gen.dart',
    );
    await buildStep.writeAsString(outputId, buffer.toString());
  }

  String _formatBullets(String text) {
    return text
        .split('\n')
        .map((line) {
          final trimmed = line.trim();
          if (trimmed.startsWith('- ')) {
            return '• ${trimmed.substring(2)}';
          }
          return line;
        })
        .join('\n')
        .trim();
  }
}

Builder changelogBuilder(BuilderOptions options) => ChangelogBuilder();
