import 'dart:io';
import 'dart:typed_data';

import 'package:dart_book/dart_book.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:re_ucm_core/re_ucm_core.dart' hide logger;
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:share_plus/share_plus.dart';

class BookSharer {
  Future<void> shareBook({
    required Uint8List bytes,
    required BookMetadata metadata,
    required SaveFormat format,
    required Portal portal,
    Book? resolvedBook,
  }) async {
    final name = _buildShareFileName(metadata);
    final ext = format.ext;
    final mimeType = format.mimeType;

    final tempDir = (await getTemporaryDirectory()).path;
    final filePath = p.join(tempDir, '$name$ext');
    final tempFile = File(filePath);
    await tempFile.writeAsBytes(bytes);

    final xfile = XFile(filePath, name: '$name$ext', mimeType: mimeType);

    final authors = metadata.contributors
        .map((e) => e.name.toDisplayString())
        .join(', ');

    final statusText = _buildStatusText(metadata, resolvedBook);

    final text =
        '${metadata.title}'
        '\nАвторы: $authors'
        '${metadata.primarySeries == null ? '' : '\nСерия: ${metadata.primarySeries!.name} #${metadata.primarySeries!.number}'}'
        '$statusText';

    await SharePlus.instance.share(
      ShareParams(files: [xfile], text: text, subject: name),
    );
  }

  String _buildShareFileName(BookMetadata data) {
    final primarySeries = data.primarySeries;
    var name = primarySeries != null
        ? '${primarySeries.name}–${primarySeries.number}'
        : data.title;
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');
  }

  String _buildStatusText(BookMetadata data, Book? resolvedBook) {
    if (data.isFinished) {
      return '\n\nПолностью';
    }
    final sections =
        resolvedBook?.content.blocks.whereType<BookSection>().toList() ??
        const [];
    final lastChapter = sections.length > 1
        ? sections[sections.length - 2]
        : (sections.isNotEmpty ? sections.first : null);
    final lastTitle = lastChapter != null
        ? _inlinesToPlainText(lastChapter.title).trim()
        : '';
    return lastTitle.isNotEmpty ? '\n\nПо: «$lastTitle»' : '';
  }

  String _inlinesToPlainText(List<BookInline> inlines) {
    final buffer = StringBuffer();
    for (final inline in inlines) {
      switch (inline) {
        case BookText t:
          buffer.write(t.text);
        case BookEmphasis e:
          buffer.write(_inlinesToPlainText(e.children));
        case BookStrong s:
          buffer.write(_inlinesToPlainText(s.children));
        case BookStrike st:
          buffer.write(_inlinesToPlainText(st.children));
        case BookNamedStyle n:
          buffer.write(_inlinesToPlainText(n.inlines));
        case BookLink l:
          buffer.write(_inlinesToPlainText(l.children));
        case BookSuperscript sup:
          buffer.write(_inlinesToPlainText(sup.children));
        case BookSubscript sub:
          buffer.write(_inlinesToPlainText(sub.children));
        default:
          break;
      }
    }
    return buffer.toString();
  }
}
