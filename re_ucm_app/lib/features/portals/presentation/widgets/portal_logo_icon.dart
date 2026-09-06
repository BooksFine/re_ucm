import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:re_ucm_core/models/portal.dart';

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
    final isMonochrome = portal.code != 'litres';
    final effectiveColor = (color ?? cs.onSurface).withValues(alpha: opacity);

    Widget svg = SvgPicture(
      SvgAssetLoader(
        portal.logo.assetPath,
        packageName: portal.logo.packageName,
      ),
      width: size,
      height: size,
      colorFilter: isMonochrome
          ? ColorFilter.mode(effectiveColor, BlendMode.srcIn)
          : null,
    );

    if (!isMonochrome && opacity < 1.0) {
      svg = Opacity(opacity: opacity, child: svg);
    }

    return svg;
  }
}
