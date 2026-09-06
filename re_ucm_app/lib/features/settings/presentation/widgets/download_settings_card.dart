import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/ui/widgets/widgets.dart';
import '../settings_controller.cg.dart';

class DownloadSettingsCard extends StatelessWidget {
  const DownloadSettingsCard({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      icon: Icons.download_for_offline_rounded,
      titleWidget: AppCardTitle.text('Скачивание'),
      subtitleWidget: const AppCardSubtitle(
        text: 'Формат книг и количество одновременных загрузок',
      ),
      children: [
        const AppSectionHeader('Формат по умолчанию'),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Observer(
            builder: (_) => SegmentedButton<SaveFormat>(
              showSelectedIcon: false,
              segments: [
                for (final fmt in SaveFormat.displayValues)
                  ButtonSegment<SaveFormat>(
                    value: fmt,
                    label: Text(fmt.label),
                  ),
              ],
              selected: {controller.saveFormat},
              onSelectionChanged: (newSelection) {
                if (newSelection.isNotEmpty) {
                  controller.updateSaveFormat(newSelection.first);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        const AppSectionHeader('Одновременные загрузки'),
        const SizedBox(height: 12),
        Observer(
          builder: (_) => AppCounterRow(
            title: 'Потоков для глав',
            subtitle: 'Одновременных запросов при скачивании текста',
            value: controller.parallelChapterDownloads,
            min: 1,
            max: 16,
            onChanged: controller.updateParallelChapterDownloads,
          ),
        ),
        const SizedBox(height: 12),
        Observer(
          builder: (_) => AppCounterRow(
            title: 'Потоков для иллюстраций',
            subtitle: 'Одновременных запросов при скачивании картинок',
            value: controller.parallelImageDownloads,
            min: 1,
            max: 16,
            onChanged: controller.updateParallelImageDownloads,
          ),
        ),
      ],
    );
  }
}
