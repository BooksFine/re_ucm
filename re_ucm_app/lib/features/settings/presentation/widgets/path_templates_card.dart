import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/di.dart';
import '../../../../core/ui/tokens.dart';
import '../../../../core/ui/widgets/widgets.dart';
import '../save_settings/path_template_field.dart';
import '../settings_controller.cg.dart';

class PathTemplatesCard extends StatelessWidget {
  const PathTemplatesCard({super.key, this.controller});

  final SettingsController? controller;

  @override
  Widget build(BuildContext context) {
    final effectiveController =
        controller ?? AppDependencies.of(context).settingsController;

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
            initialPath: effectiveController.downloadPathTemplate.seriesPath,
            onChanged: (newPath) {
              effectiveController.updateDownloadPathTemplate(
                effectiveController.downloadPathTemplate.copyWith(
                  seriesPath: newPath,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Observer(
          builder: (_) => PathTemplateField(
            title: 'Одиночные книги',
            initialPath: effectiveController.downloadPathTemplate.path,
            placeholders: const [
              PathPlaceholders.name,
              PathPlaceholders.authors,
              PathPlaceholders.portal,
            ],
            onChanged: (newPath) {
              effectiveController.updateDownloadPathTemplate(
                effectiveController.downloadPathTemplate.copyWith(path: newPath),
              );
            },
          ),
        ),
      ],
    );
  }
}
