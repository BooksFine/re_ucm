import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../tokens.dart';

class PortalBadge extends StatelessWidget {
  const PortalBadge({super.key, required this.portal});

  final Portal portal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
      child: Text(
        portal.name,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
