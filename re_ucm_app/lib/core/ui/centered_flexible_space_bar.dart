import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Дистанции/подъёмы оптического центрирования заголовка.
const double _kScrollUnderFadeDistance = 40.0;
const double _kCollapsedLift = 4.0;
const double _kExpandedShift = 10.0;

/// A flexible space bar that centers the title both horizontally and vertically
/// when expanded, and smoothly morphs (scales and translates) into the pinned
/// toolbar center when collapsed.
class CenteredFlexibleSpaceBar extends StatefulWidget {
  const CenteredFlexibleSpaceBar({
    super.key,
    required this.title,
    this.expandedTitleScale = 1.4,
  });

  final Widget title;
  final double expandedTitleScale;

  @override
  State<CenteredFlexibleSpaceBar> createState() =>
      _CenteredFlexibleSpaceBarState();
}

class _CenteredFlexibleSpaceBarState extends State<CenteredFlexibleSpaceBar> {
  ScrollPosition? _position;
  double? _lastDeltaExtent;
  double _lastScrollUnderFade = 1.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeListener();
    _position = Scrollable.maybeOf(context)?.position;
    _position?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  void _removeListener() {
    _position?.removeListener(_onScroll);
    _position = null;
  }

  double _calculateScrollUnderFade(double deltaExtent) {
    final double scrollOffset = _position?.hasPixels == true
        ? _position!.pixels
        : 0.0;
    final double overScroll = math.max(0.0, scrollOffset - deltaExtent);
    return 1.0 -
        ui.clampDouble(
          overScroll / _kScrollUnderFadeDistance,
          0.0,
          1.0,
        );
  }

  void _onScroll() {
    final double? deltaExtent = _lastDeltaExtent;
    if (deltaExtent == null) {
      setState(() {});
      return;
    }

    final double scrollUnderFade = _calculateScrollUnderFade(deltaExtent);
    if (scrollUnderFade == _lastScrollUnderFade) {
      return;
    }
    _lastScrollUnderFade = scrollUnderFade;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final FlexibleSpaceBarSettings? settings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
        if (settings == null) {
          return widget.title;
        }

        final double deltaExtent = settings.maxExtent - settings.minExtent;
        _lastDeltaExtent = deltaExtent;
        final double t = deltaExtent > 0
            ? ui.clampDouble(
                1.0 -
                    (settings.currentExtent - settings.minExtent) / deltaExtent,
                0.0,
                1.0,
              )
            : 1.0;

        final ThemeData theme = Theme.of(context);
        final double opacity = settings.toolbarOpacity;

        // When collapsed (t = 1.0), as cards scroll further up under the transparent toolbar,
        // fade out over the next 40px of scroll.
        final double scrollUnderFade = _calculateScrollUnderFade(deltaExtent);
        _lastScrollUnderFade = scrollUnderFade;

        final double effectiveOpacity = opacity * scrollUnderFade;

        final TextStyle baseStyle = theme.appBarTheme.titleTextStyle ??
            (theme.useMaterial3
                ? theme.textTheme.titleLarge!
                : theme.primaryTextTheme.titleLarge!);

        TextStyle titleStyle = baseStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: (baseStyle.color ?? theme.colorScheme.onSurface)
              .withValues(alpha: effectiveOpacity),
        );

        final double scale = ui.lerpDouble(widget.expandedTitleScale, 1.0, t)!;

        final double topInset = MediaQuery.paddingOf(context).top;
        // Balance optical distance between window top and the cards below
        final double collapsedCenterY =
            topInset +
            (settings.minExtent - topInset) / 2.0 +
            _kCollapsedLift;
        // Shift expanded center slightly down for optical balance
        final double expandedCenterY =
            topInset +
            (settings.currentExtent - topInset) / 2.0 +
            _kExpandedShift;
        final double currentCenterY = ui.lerpDouble(
          expandedCenterY,
          collapsedCenterY,
          t,
        )!;

        final double bgAlpha = AppOpacity.scrimPeak * t;

        return ClipRect(
          child: Stack(
            children: [
              if (t > 0.0 && topInset > 0.0)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: topInset,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.surface.withValues(alpha: bgAlpha),
                          theme.colorScheme.surface.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              if (effectiveOpacity > 0.0)
                Positioned(
                  top: currentCenterY,
                  left: 0,
                  right: 0,
                  child: FractionalTranslation(
                    translation: const Offset(0.0, -0.5),
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.center,
                      child: DefaultTextStyle(
                        style: titleStyle,
                        textAlign: TextAlign.center,
                        child: Center(child: widget.title),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
