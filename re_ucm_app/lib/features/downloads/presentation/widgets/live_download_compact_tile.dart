import 'package:material_ui/material_ui.dart';
import '../../domain/download_task.cg.dart';
import 'download_task_tile.dart';

export 'download_task_tile.dart';

/// Компактный тайл активной загрузки для live-карточки.
class LiveDownloadCompactTile extends StatelessWidget {
  const LiveDownloadCompactTile({
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
      trailingType: DownloadTileTrailingType.cancel,
    );
  }
}

