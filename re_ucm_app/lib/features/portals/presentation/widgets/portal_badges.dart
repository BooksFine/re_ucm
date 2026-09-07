import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_colors_extension.dart';

/// Бейдж статуса авторизации: точка + «Подключен»/«Без входа».
/// Размер точки унифицирован (6) — раньше дрейфовал 6 vs 5
/// между hero-карточкой и tile списка.
class PortalAuthBadge extends StatelessWidget {
  const PortalAuthBadge({
    super.key,
    required this.isAuthorized,
  });

  final bool isAuthorized;

  static const double dotSize = 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final appColors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAuthorized
                ? appColors.success
                : appColors.statusOffline,
          ),
        ),
        const SizedBox(width: 5),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            isAuthorized ? 'Подключен' : 'Без входа',
            key: ValueKey(isAuthorized),
            style: theme.textTheme.labelSmall?.copyWith(
              color: isAuthorized
                  ? appColors.success
                  : cs.onSurfaceVariant,
              fontWeight: isAuthorized ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Общий scale+fade transition для переключения пина.
/// Используется в AppBar, tile и hero-кнопке.
class PortalPinScaleTransition extends StatelessWidget {
  const PortalPinScaleTransition({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: child,
    );
  }
}

/// Кнопка-звезда пина для AppBar и tile списка.
class PortalPinIconButton extends StatelessWidget {
  const PortalPinIconButton({
    super.key,
    required this.isPinned,
    required this.onTogglePin,
  });

  final bool isPinned;
  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IconButton(
      icon: PortalPinScaleTransition(
        child: Icon(
          isPinned ? Icons.star_rounded : Icons.star_outline_rounded,
          key: ValueKey(isPinned),
          color: isPinned ? cs.primary : cs.onSurfaceVariant,
          size: 22,
        ),
      ),
      tooltip: isPinned ? 'Открепить' : 'Закрепить',
      visualDensity: VisualDensity.compact,
      onPressed: () {
        HapticFeedback.lightImpact();
        onTogglePin();
      },
    );
  }
}
