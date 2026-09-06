import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

import '../tokens.dart';

/// Файл заморожен по поведению: здесь только токенизация магических
/// чисел в именованные константы, логика и API не меняются.
const double _kEdgeMargin = 12.0;
const double _kItemExtent = 44.0;
const double _kMenuChrome = 16.0;
const double _kMenuMinHeight = 60.0;
const double _kMenuMaxHeight = 360.0;
const double _kStartScale = 0.72;
const double _kScaleRange = 0.28;
const double _kShadowBlur = 16.0;
const Offset _kShadowOffset = Offset(0, 6);
const double _kItemIconSize = 19.0;
const double _kCheckIconSize = 18.0;
const double _kIconGap = 12.0;
const double _kCheckGap = 8.0;
const double _kItemFontSize = 13.0;
const double _kMenuVPadding = 6.0;
const double _kMenuHPadding = 4.0;
const double _kItemVPadding = 10.0;
const double _kItemHPadding = 12.0;

class M3ESpringPopupItem<T> {
  const M3ESpringPopupItem({
    required this.value,
    this.label,
    this.icon,
    this.child,
    this.isSelected = false,
    this.isDestructive = false,
  });

  final T value;
  final String? label;
  final IconData? icon;
  final Widget? child;
  final bool isSelected;
  final bool isDestructive;
}

/// Shows a Material 3 Expressive popup menu anchored to [targetContext]
/// with spring entrance motion powered by [motor] and NO background dimming.
Future<T?> showM3ESpringPopup<T>({
  required BuildContext targetContext,
  required List<M3ESpringPopupItem<T>> items,
  Offset offset = const Offset(0, 4),
  double width = 210,
}) {
  final completer = Completer<T?>();
  final renderBox = targetContext.findRenderObject() as RenderBox?;
  if (renderBox == null || !targetContext.mounted) {
    return Future.value(null);
  }

  final overlay = Overlay.of(targetContext);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => _M3ESpringPopupOverlay<T>(
      items: items,
      triggerBox: renderBox,
      offset: offset,
      menuWidth: width,
      onSelected: (val) {
        HapticFeedback.lightImpact();
        completer.complete(val);
      },
      onDismiss: () {
        completer.complete(null);
      },
      onRemove: () {
        entry.remove();
      },
    ),
  );

  overlay.insert(entry);
  return completer.future;
}

class _M3ESpringPopupOverlay<T> extends StatefulWidget {
  const _M3ESpringPopupOverlay({
    required this.items,
    required this.triggerBox,
    required this.offset,
    required this.menuWidth,
    required this.onSelected,
    required this.onDismiss,
    required this.onRemove,
  });

  final List<M3ESpringPopupItem<T>> items;
  final RenderBox triggerBox;
  final Offset offset;
  final double menuWidth;
  final ValueChanged<T> onSelected;
  final VoidCallback onDismiss;
  final VoidCallback onRemove;

  @override
  State<_M3ESpringPopupOverlay<T>> createState() => _M3ESpringPopupOverlayState<T>();
}

class _M3ESpringPopupOverlayState<T> extends State<_M3ESpringPopupOverlay<T>> {
  double _springTarget = 0.0;
  bool _isDismissing = false;
  double _opacity = 0.0;

  final SpringMotion _motion = MaterialSpringMotion.expressiveEffectsFast().copyWith(
    stiffness: 1100,
    damping: 0.62,
    snapToEnd: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _springTarget = 1.0;
          _opacity = 1.0;
        });
      }
    });
  }

  void _dismiss({T? selectedValue}) {
    if (_isDismissing) return;
    setState(() {
      _isDismissing = true;
      _springTarget = 0.0;
      _opacity = 0.0;
    });

    Future.delayed(AppDurations.exit, () {
      if (selectedValue != null) {
        widget.onSelected(selectedValue);
      } else {
        widget.onDismiss();
      }
      widget.onRemove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final media = MediaQuery.of(context);
    final screenSize = media.size;

    final triggerTopLeft = widget.triggerBox.localToGlobal(Offset.zero);
    final triggerBottomRight = widget.triggerBox.localToGlobal(
      widget.triggerBox.size.bottomRight(Offset.zero),
    );

    final spaceBelow =
        screenSize.height - triggerBottomRight.dy - _kEdgeMargin;
    final spaceAbove = triggerTopLeft.dy - _kEdgeMargin;
    final approxHeight = widget.items.length * _kItemExtent + _kMenuChrome;
    final showAbove = spaceBelow < approxHeight && spaceAbove > spaceBelow;

    // Anchor popup to the right edge of the trigger button with margin clamping
    final right = (screenSize.width - triggerBottomRight.dx - widget.offset.dx)
        .clamp(
          _kEdgeMargin,
          (screenSize.width - widget.menuWidth - _kEdgeMargin).clamp(
            _kEdgeMargin,
            double.infinity,
          ),
        );

    final top = showAbove
        ? null
        : triggerBottomRight.dy + widget.offset.dy;
    final bottom = showAbove
        ? screenSize.height - triggerTopLeft.dy + widget.offset.dy
        : null;

    final scaleAlignment = Alignment(
        1.0,
        showAbove ? 1.0 : -1.0,
    );

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          _dismiss();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Completely transparent tap catcher (NO screen dimming)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _dismiss(),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),

            // Spring animated menu container
            Positioned(
              right: right,
              top: top,
              bottom: bottom,
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: _isDismissing
                    ? AppDurations.fadeOut
                    : AppDurations.fadeIn,
                curve: Curves.easeOut,
                child: SingleMotionBuilder(
                  motion: _motion,
                  value: _springTarget,
                  builder: (context, t, _) {
                    final scale = _kStartScale + (t * _kScaleRange);

                    return Transform.scale(
                      scale: scale,
                      alignment: scaleAlignment,
                      child: Container(
                        width: widget.menuWidth,
                        constraints: BoxConstraints(
                          maxHeight: (showAbove ? spaceAbove : spaceBelow)
                              .clamp(_kMenuMinHeight, _kMenuMaxHeight),
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainer,
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(
                              alpha: AppOpacity.soft,
                            ),
                            width: AppBorderWidth.thin,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: AppOpacity.shadow,
                              ),
                              blurRadius: _kShadowBlur,
                              offset: _kShadowOffset,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            vertical: _kMenuVPadding,
                            horizontal: _kMenuHPadding,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final item in widget.items)
                                _buildMenuItem(context, cs, item),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    ColorScheme cs,
    M3ESpringPopupItem<T> item,
  ) {
    final color = item.isDestructive ? cs.error : cs.onSurface;
    final iconColor = item.isDestructive ? cs.error : cs.onSurfaceVariant;
    final bgColor = item.isSelected ? cs.secondaryContainer : Colors.transparent;
    final selectedTextColor = item.isSelected ? cs.onSecondaryContainer : color;

    Widget content;
    if (item.child != null) {
      content = item.child!;
    } else {
      content = Row(
        children: [
          if (item.icon != null) ...[
            Icon(
              item.icon,
              size: _kItemIconSize,
              color: item.isSelected ? cs.onSecondaryContainer : iconColor,
            ),
            const SizedBox(width: _kIconGap),
          ],
          Expanded(
            child: Text(
              item.label ?? '',
              style: TextStyle(
                fontSize: _kItemFontSize,
                fontWeight: item.isSelected ? FontWeight.w600 : FontWeight.w500,
                color: selectedTextColor,
              ),
            ),
          ),
          if (item.isSelected) ...[
            const SizedBox(width: _kCheckGap),
            Icon(
              Icons.check_rounded,
              size: _kCheckIconSize,
              color: cs.onSecondaryContainer,
            ),
          ],
        ],
      );
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: () => _dismiss(selectedValue: item.value),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _kItemHPadding,
            vertical: _kItemVPadding,
          ),
          child: content,
        ),
      ),
    );
  }
}
