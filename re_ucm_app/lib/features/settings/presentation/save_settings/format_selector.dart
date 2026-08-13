import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:re_ucm_lib/settings/domain/save_format.dart';

import '../../../../core/ui/constants.dart';
import '../settings_controller.cg.dart';

class FormatSelector extends StatelessWidget {
  const FormatSelector({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final currentFormat = controller.saveFormat;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Формат сохранения:',
                style: TextStyle(
                  fontSize: 16,
                  color: ColorScheme.of(context).onSurfaceVariant,
                ),
              ),
              const SizedBox(height: appPadding),
              SizedBox(
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
                  selected: {currentFormat},
                  onSelectionChanged: (Set<SaveFormat> newSelection) {
                    if (newSelection.isNotEmpty) {
                      controller.updateSaveFormat(newSelection.first);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
