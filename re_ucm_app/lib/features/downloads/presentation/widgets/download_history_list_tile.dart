import 'package:material_ui/material_ui.dart';
import '../../domain/download_task.cg.dart';
import 'download_task_tile.dart';

export 'download_task_tile.dart';

/// Тайл задачи для карточек в модалке со списком загрузок.
class DownloadHistoryListTile extends StatelessWidget {
  const DownloadHistoryListTile({
    super.key,
    required this.task,
    this.onTap,
  });

  final DownloadTask task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DownloadTaskTile(
      task: task,
      onTap: onTap,
      trailingType: DownloadTileTrailingType.chevron,
    );
  }
}

