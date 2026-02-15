import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

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
          child: controller.bookXmlBytes == null
              ? ElevatedButton1(
                  isLoading: controller.isDownloading,
                  func: controller.download,
                  child: const Text('СКАЧАТЬ'),
                )
              : Column(
                  children: [
                    ElevatedButton1(
                      func: controller.share,
                      child: const Text('Поделиться'),
                    ),
                    const SizedBox(height: appPadding),
                    OutlinedButton1(text: 'Сохранить', func: controller.save),
                  ],
                ),
        );
      },
    );
  }
}
