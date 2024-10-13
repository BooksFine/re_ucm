import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../../core/constants.dart';
import '../../common/widgets/appbar.dart';
import '../../common/widgets/shimmer.dart';
import '../../settings/presentation/settings_dialog.dart';
import 'book_page_controller.cg.dart';
import 'widgets/annotation_viewer.dart';
import 'widgets/book_actions_bar.dart';
import 'widgets/book_header.dart';
import 'widgets/book_page_skeleton.dart';
import 'widgets/error_message.dart';
import 'widgets/progress_bar.dart';

class BookPage extends StatefulWidget {
  const BookPage({
    super.key,
    required this.id,
    required this.portal,
  });

  final String id;
  final Portal portal;

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  late BookPageController controller;

  void updateController() =>
      controller = BookPageController(id: widget.id, portal: widget.portal);

  @override
  void initState() {
    super.initState();
    return updateController();
  }

  @override
  void didUpdateWidget(covariant BookPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id || widget.portal != oldWidget.portal) {
      updateController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer.withBuiltChild(
      builderWithChild: (context, child) {
        return PopScope(
          canPop: controller.canPop,
          child: child!,
        );
      },
      child: Scaffold(
        key: controller.scaffoldKey,
        appBar: MyAppBar(
          title: 'ReUCM',
          leading: IconButton(
            onPressed: controller.pop,
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
          actions: [
            IconButton(
              onPressed: () => openSettingsDialog(context),
              icon: const Icon(Icons.settings),
            )
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: RefreshIndicator(
              onRefresh: () async => controller.fetch(),
              child: Observer(builder: (context) {
                return AnimatedSwitcher(
                  duration: Durations.medium2,
                  child: switch (controller.book.status) {
                    FutureStatus.pending => const ShimmerEffect(
                        key: ValueKey('shimmer'),
                        BookPageSkeleton(),
                      ),
                    FutureStatus.rejected => ErrorMessage(
                        controller: controller,
                      ),
                    FutureStatus.fulfilled => ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: appPadding * 2,
                        ),
                        children: [
                          const SizedBox(height: appPadding),
                          BookHeader(book: controller.book.value!),
                          const SizedBox(height: appPadding * 2),
                          BookActionsBar(controller: controller),
                          ProgressBar(controller: controller),
                          if (controller.book.value!.annotation != null)
                            AnnotationViewer(
                              annotation: controller.book.value!.annotation!,
                            ),
                          const SizedBox(height: appPadding * 2),
                          SizedBox(
                            height: MediaQuery.paddingOf(context).bottom,
                          ),
                        ],
                      ),
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
