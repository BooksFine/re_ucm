import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../../../core/ui/tokens.dart';
import 'portal_logo_icon.dart';

class PortalLogoContainer extends StatelessWidget {
  const PortalLogoContainer({
    super.key,
    required this.portal,
    this.size = 44,
    this.padding = 8,
  });

  final Portal portal;
  final double size;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: PortalLogoIcon(
        portal: portal,
        color: cs.onSurface,
      ),
    );
  }
}
