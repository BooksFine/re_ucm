import 'package:material_ui/material_ui.dart';
import '../../domain/download_task.cg.dart';
import '../../domain/downloads_service.cg.dart';
import 'download_history_list_tile.dart';
import 'live_download_compact_tile.dart';

export 'download_history_list_tile.dart';
export 'live_download_compact_tile.dart';

/// Ключ тайла — через единый [DownloadsServiceBase.taskKey].
ValueKey<String> downloadTileKey(DownloadTask task) =>
    ValueKey<String>(DownloadsServiceBase.taskKey(task.session.portal.code, task.bookId));

/// Фасадный тайл задачи для обратной совместимости.
/// Для новых мест используйте напрямую [LiveDownloadCompactTile] или [DownloadHistoryListTile].
class DownloadListTile extends StatelessWidget {
  const DownloadListTile({
    super.key,
    required this.task,
    this.onTap,
    this.compact = false,
  });

  final DownloadTask task;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return LiveDownloadCompactTile(
        task: task,
        onTap: onTap,
      );
    }
    return DownloadHistoryListTile(
      task: task,
      onTap: onTap,
    );
  }
}
