import 'package:material_ui/material_ui.dart';

import '../../../core/navigation/nav.dart';
import '../../../core/ui/tokens.dart';
import '../../../core/ui/widgets/app_section_header.dart';
import '../../downloads/presentation/widgets/live_download_card.dart';
import '../../portals/presentation/portals_list.dart';
import 'link_forwarder.dart';

/// Общий состав главной: ссылка → браузер → живые загрузки.
/// Layout (Row vs slivers, внешние паддинги) остаётся в
/// landscape/portrait — здесь только «что показываем», чтобы порядок
/// и секции не разъезжались между двумя файлами.
///
/// [contentPadding] применяется к ссылке и загрузкам; карусель
/// порталов всегда full-bleed (у неё собственные внутренние отступы).
class HomeActionHub extends StatelessWidget {
  const HomeActionHub({
    super.key,
    required this.isWide,
    this.headerPadding = EdgeInsets.zero,
    this.contentPadding = EdgeInsets.zero,
  });

  final bool isWide;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: contentPadding,
          child: LinkForwarder(isWide: isWide),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppSectionHeader('Браузер', padding: headerPadding),
        PortalsList(onTap: (portal) => Nav.goBrowser(portal.code)),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: contentPadding,
          child: LiveDownloadCard(isWide: isWide),
        ),
      ],
    );
  }
}
