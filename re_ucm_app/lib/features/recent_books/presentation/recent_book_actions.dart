import 'dart:io';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/di.dart';
import '../../common/widgets/overlay_snack.dart';
import '../../downloads/domain/download_task.cg.dart';
import '../../downloads/presentation/download_modal.dart';
import '../../downloads/presentation/widgets/unauthorized_download_dialog.dart';

export 'recent_book_utils.dart';
export 'recent_book_widgets.dart';

Future<void> openDownloadedFile(
  BuildContext context,
  String filePath,
) async {
  HapticFeedback.lightImpact();
  final file = File(filePath);
  if (!file.existsSync()) {
    if (context.mounted) {
      overlaySnackMessage(
        context,
        'Файл книги не найден на диске (возможно, перемещён или удалён)',
      );
    }
    return;
  }
  await OpenFile.open(filePath);
}

Future<void> shareBook(
  BuildContext context,
  DownloadTask? task,
  String? effectiveFilePath,
  RecentBook book,
) async {
  HapticFeedback.lightImpact();

  if (task != null && task.savedFilePath != null && task.isCompleted) {
    await task.share();
    return;
  }

  if (effectiveFilePath != null && File(effectiveFilePath).existsSync()) {
    final fileName = p.basename(effectiveFilePath);
    final xfile = XFile(effectiveFilePath, name: fileName);
    final text =
        '«${book.title}»\nАвтор: ${book.authors}\nИсточник: ${book.portal.name}';

    await SharePlus.instance.share(
      ShareParams(files: [xfile], text: text, subject: book.title),
    );
    return;
  }

  final portalName = book.portal.name;
  final text =
      '«${book.title}»\nАвтор: ${book.authors}\nИсточник: $portalName';
  await SharePlus.instance.share(
    ShareParams(text: text, subject: book.title),
  );
}

Future<void> startDownload(
  BuildContext context,
  PortalSession session,
  SaveFormat format,
  String bookId,
) async {
  final deps = AppDependencies.of(context);
  final shouldProceed = await checkAndConfirmUnauthorizedDownload(
    context: context,
    session: session,
    settingsService: deps.settingsService,
  );
  if (!shouldProceed || !context.mounted) return;

  final downloadsService = deps.downloadsService;
  final task = downloadsService.getOrCreateTask(
    session: session,
    bookId: bookId,
  );
  task.updateSaveFormat(format);
  if (!task.isActive) {
    task.start();
  }
  showDownloadModalForTask(context, task);
}

Future<void> openBook(
  BuildContext context, {
  required DownloadTask? task,
  required String? effectiveFilePath,
}) async {
  if (task != null && task.isCompleted && task.savedFilePath != null) {
    task.open();
  } else if (effectiveFilePath != null) {
    await openDownloadedFile(context, effectiveFilePath);
  }
}
