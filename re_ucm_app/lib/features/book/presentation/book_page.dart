import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../../core/ui/constants.dart';
import '../../common/widgets/appbar.dart';
import '../../common/widgets/shimmer.dart';
import '../../recent_books/application/recent_books_service.dart';
import '../../settings/application/settings_service.cg.dart';
import '../../settings/presentation/settings_dialog.dart';
import 'book_page_controller.cg.dart';
import 'widgets/annotation_viewer.dart';
import 'widgets/book_actions_bar.dart';
import 'widgets/book_header.dart';
import 'widgets/book_page_skeleton.dart';
import 'widgets/error_message.dart';
import 'widgets/progress_bar.dart';
import 'widgets/unauthorized_alert.dart';

class BookPage extends StatefulWidget {
  const BookPage({
    super.key,
    required this.id,
    required this.portal,
    required this.settings,
    required this.recentBooksService,
  });

  final String id;
  final Portal portal;
  final SettingsService settings;
  final RecentBooksService recentBooksService;

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  late BookPageController controller;

  void updateController() => controller = BookPageController(
    id: widget.id,
    portal: widget.portal,
    settings: widget.settings,
    recentBooksService: widget.recentBooksService,
  );

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
      builder: (context, child) {
        return PopScope(canPop: controller.canPop, child: child);
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
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: RefreshIndicator(
              onRefresh: () async => controller.fetch(),
              child: Observer(
                builder: (context) {
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
                          const SizedBox(height: appPadding),
                          if (!controller.isAuthorized)
                            UnauthorizedAlert(portal: controller.portal.name),
                          const SizedBox(height: appPadding),
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
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
