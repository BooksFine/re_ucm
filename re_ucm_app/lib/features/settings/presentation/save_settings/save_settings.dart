import 'package:flutter/material.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/ui/constants.dart';
import '../../presentation/settings_controller.cg.dart';
import 'authors_separator_field.dart';
import 'path_template_card.dart';
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
        PathTemplateCard(
          title: 'Шаблон для произведений в серии',
          path: controller.downloadPathTemplate.seriesPath,
          onChanged: (newPath) {
            controller.updateDownloadPathTemplate(
              controller.downloadPathTemplate.copyWith(seriesPath: newPath),
            );
          },
        ),
        const SizedBox(height: appPadding),
        PathTemplateCard(
          title: 'Шаблон для одиночных произведений',
          path: controller.downloadPathTemplate.path,
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
      ],
    );
  }
}
