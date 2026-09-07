import 'dart:async';

import 'package:dart_book/dart_book.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/di.dart';
import '../../../../core/navigation/nav.dart';
import '../../domain/download_task.cg.dart';
import '../download_modal.dart';
import '../widgets/unauthorized_download_dialog.dart';

/// Утилита централизованной подготовки и старта скачивания с подтверждением авторизации.
abstract final class DownloadStarter {
  /// Проверяет права (авторизацию), создаёт/получает задачу скачивания,
  /// устанавливает формат сохранения, запускает задачу и открывает модальное окно.
  ///
  /// Возвращает запущенный [DownloadTask], если скачивание было подтверждено,
  /// либо `null`, если пользователь отменил диалог или контекст потерял валидность.
  static Future<DownloadTask?> startWithConfirmation({
    required BuildContext context,
    required PortalSession session,
    required String bookId,
    required SaveFormat format,
    BookMetadata? initialMetadata,
  }) async {
    final deps = AppDependencies.of(context);
    final shouldProceed = await checkAndConfirmUnauthorizedDownload(
      context: context,
      session: session,
      settingsService: deps.settingsService,
      onLogin: () => Nav.goSourceDetails(session.portal.code),
    );
    if (!shouldProceed || !context.mounted) return null;

    final downloadsService = deps.downloadsService;
    final task = downloadsService.getOrCreateTask(
      session: session,
      bookId: bookId,
      initialMetadata: initialMetadata,
    );
    task.updateSaveFormat(format);
    if (!task.isActive) {
      unawaited(task.start());
    }
    if (context.mounted) {
      await showDownloadModalForTask(context, task);
    }
    return task;
  }
}
