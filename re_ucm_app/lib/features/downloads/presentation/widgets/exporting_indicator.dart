import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/download_task.cg.dart';

class ExportingIndicator extends StatelessWidget {
  const ExportingIndicator({
    super.key,
    required this.task,
    required this.icon,
    this.size = 20,
    this.color,
  });

  final DownloadTask task;
  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (task.isExporting) {
      return SizedBox(
        width: size,
        height: size,
        child: M3ECircularWavyProgressIndicator(
          size: size,
          strokeWidth: 2,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return Icon(icon, size: size);
  }
}
