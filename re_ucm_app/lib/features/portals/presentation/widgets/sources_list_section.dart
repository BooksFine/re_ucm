import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/widgets/app_section_header.dart';

class SourcesSectionHeader extends StatelessWidget {
  const SourcesSectionHeader({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.only(left: 4, bottom: 8),
  });

  final String title;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AppSectionHeader(
      title,
      padding: padding,
    );
  }
}
