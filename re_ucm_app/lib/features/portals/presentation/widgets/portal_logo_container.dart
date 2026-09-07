import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../../../core/ui/tokens.dart';

/// Renders a portal logo with appropriate color handling.
///
/// Full-color brand logos (e.g. Litres) retain their authentic colors,
/// while monochrome vector logos (e.g. Author Today, Ficbook) adapt
/// to the theme's [onSurface] color so they are crisp and visible
/// across both light and dark themes.
class PortalLogoIcon extends StatelessWidget {
  const PortalLogoIcon({
    super.key,
    required this.portal,
    this.size,
    this.color,
    this.opacity = 1.0,
  });

  final Portal portal;
  final double? size;
  final Color? color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveColor = (color ?? cs.onSurface).withValues(alpha: opacity);

    return SvgPicture(
      SvgAssetLoader(
        portal.logo.assetPath,
        packageName: portal.logo.packageName,
      ),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}

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
