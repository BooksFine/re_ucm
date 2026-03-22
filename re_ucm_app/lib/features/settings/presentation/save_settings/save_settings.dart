import 'package:flutter/material.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/ui/constants.dart';
import '../../presentation/settings_controller.cg.dart';
import 'authors_separator_field.dart';
import 'format_selector.dart';
import 'path_template_field.dart';
import 'save_directory_field.dart';

class SaveSettings extends StatelessWidget {
  const SaveSettings({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SaveDirectoryField(controller: controller),
        const SizedBox(height: appPadding * 2),
        PathTemplateField(
          title: 'Шаблон для книг в серии',
          initialPath: controller.downloadPathTemplate.seriesPath,
          onChanged: (newPath) {
            controller.updateDownloadPathTemplate(
              controller.downloadPathTemplate.copyWith(seriesPath: newPath),
            );
          },
        ),
        const SizedBox(height: appPadding),
        PathTemplateField(
          title: 'Шаблон для одиночных книг',
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
        const SizedBox(height: appPadding),
        AuthorsSeparatorField(controller: controller),
        const SizedBox(height: appPadding * 2),
        FormatSelector(),
      ],
    );
  }
}
