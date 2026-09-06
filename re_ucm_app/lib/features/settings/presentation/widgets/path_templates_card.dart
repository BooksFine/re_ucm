import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/ui/widgets/widgets.dart';
import '../save_settings/path_template_field.dart';
import '../settings_controller.cg.dart';

class PathTemplatesCard extends StatelessWidget {
  const PathTemplatesCard({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      icon: Icons.text_fields_rounded,
      titleWidget: AppCardTitle.text('Именование файлов'),
      subtitleWidget: const AppCardSubtitle(
        text: 'Шаблоны структуры папок и имён файлов',
      ),
      children: [
        Observer(
          builder: (_) => PathTemplateField(
            title: 'Книги в серии',
            initialPath: controller.downloadPathTemplate.seriesPath,
            onChanged: (newPath) {
              controller.updateDownloadPathTemplate(
                controller.downloadPathTemplate.copyWith(
                  seriesPath: newPath,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Observer(
          builder: (_) => PathTemplateField(
            title: 'Одиночные книги',
            initialPath: controller.downloadPathTemplate.path,
            placeholders: const [
              PathPlaceholders.name,
              PathPlaceholders.authors,
              PathPlaceholders.portal,
            ],
            onChanged: (newPath) {
              controller.updateDownloadPathTemplate(
                controller.downloadPathTemplate.copyWith(path: newPath),
              );
            },
          ),
        ),
      ],
    );
  }
}
