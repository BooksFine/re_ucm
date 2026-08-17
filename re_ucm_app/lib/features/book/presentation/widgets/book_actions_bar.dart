import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:re_ucm_lib/settings/domain/save_format.dart';

import '../../../../core/ui/constants.dart';
import '../../../common/widgets/btn.dart';
import '../../../common/widgets/outlined_btn.dart';
import '../book_page_controller.cg.dart';

class BookActionsBar extends StatelessWidget {
  const BookActionsBar({super.key, required this.controller});

  final BookPageController controller;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return AnimatedSize(
          duration: Durations.medium4,
          alignment: Alignment.topCenter,
          child: controller.resolvedBook == null
              ? ElevatedButton1(
                  isLoading: controller.isDownloading,
                  func: controller.download,
                  child: const Text('СКАЧАТЬ'),
                )
              : Column(
                  children: [
                    _FormatSelector(controller: controller),
                    const SizedBox(height: appPadding * 2),
                    ElevatedButton1(
                      isLoading: controller.isDownloading,
                      func: controller.share,
                      child: const Text('Поделиться'),
                    ),
                    const SizedBox(height: appPadding),
                    OutlinedButton1(
                      isLoading: controller.isDownloading,
                      text: 'Сохранить',
                      func: controller.save,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _FormatSelector extends StatelessWidget {
  const _FormatSelector({required this.controller});

  final BookPageController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Формат сохранения:',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: appPadding),
        Observer(
          builder: (context) {
            return SizedBox(
              width: double.infinity,
              child: SegmentedButton<SaveFormat>(
                style: SegmentedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cardBorderRadius),
                  ),
                ),
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment<SaveFormat>(
                    value: SaveFormat.fb2,
                    label: Text('fb2'),
                  ),
                  ButtonSegment<SaveFormat>(
                    value: SaveFormat.fb2Zip,
                    label: Text('fb2.zip'),
                  ),
                  ButtonSegment<SaveFormat>(
                    value: SaveFormat.epub,
                    label: Text('epub'),
                  ),
                ],
                selected: {controller.saveFormat},
                onSelectionChanged: (Set<SaveFormat> newSelection) {
                  if (newSelection.isNotEmpty) {
                    controller.updateSaveFormat(newSelection.first);
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }
}