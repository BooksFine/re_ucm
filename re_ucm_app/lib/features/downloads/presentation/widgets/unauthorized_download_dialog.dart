import 'package:flutter/services.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/re_ucm_core.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/navigation/router_delegate.dart';
import '../../../../core/ui/tokens.dart';

/// Показывает диалог-предупреждение, если пользователь не авторизован.
///
/// Возвращает `true`, если скачивание подтверждено.
/// Флаг «больше не спрашивать» хранится в [SettingsService]
/// (персистентно), а не в глобальной переменной процесса.
/// Навигация наружу вынесена через [onLogin] — диалог не знает про роутер.
Future<bool> checkAndConfirmUnauthorizedDownload({
  required BuildContext context,
  required PortalSession session,
  required SettingsService settingsService,
  required VoidCallback onLogin,
}) async {
  if (!session.portal.supportsAuth ||
      session.isAuthorized ||
      !settingsService.warnUnauthorizedDownloads) {
    return true;
  }

  final targetContext = Nav.contextOrNull ?? context;

  bool? dontAskAgain;
  final result = await showDialog<bool>(
    context: targetContext,
    barrierDismissible: true,
    builder: (dialogCtx) => _UnauthorizedDownloadDialog(
      session: session,
      onClose: () => Navigator.of(dialogCtx).pop(false),
      onDontAskAgainChanged: (v) => dontAskAgain = v,
    ),
  );

  if (dontAskAgain == true) {
    settingsService.updateWarnUnauthorizedDownloads(false);
  }

  if (result == null) return false;
  if (result) return true;

  // Пользователь нажал «Войти»: отдаём решение наружу.
  onLogin();
  return false;
}

class _UnauthorizedDownloadDialog extends StatefulWidget {
  const _UnauthorizedDownloadDialog({
    required this.session,
    required this.onClose,
    required this.onDontAskAgainChanged,
  });

  final PortalSession session;
  final VoidCallback onClose;
  final ValueChanged<bool> onDontAskAgainChanged;

  @override
  State<_UnauthorizedDownloadDialog> createState() =>
      _UnauthorizedDownloadDialogState();
}

class _UnauthorizedDownloadDialogState
    extends State<_UnauthorizedDownloadDialog> {
  bool _dontAskAgain = false;

  void _toggleDontAskAgain() {
    HapticFeedback.selectionClick();
    setState(() {
      _dontAskAgain = !_dontAskAgain;
    });
    widget.onDontAskAgainChanged(_dontAskAgain);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final portalName = widget.session.portal.name;

    return Dialog(
      backgroundColor: cs.surfaceContainerHigh,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.dialog),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Вы не авторизованы',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Не выполнен вход в «$portalName». '
                'Будут загружены только бесплатные главы.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  onTap: _toggleDontAskAgain,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _dontAskAgain,
                          onChanged: (value) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _dontAskAgain = value ?? false;
                            });
                            widget.onDontAskAgainChanged(_dontAskAgain);
                          },
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Больше не спрашивать',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  M3EButton(
                    style: M3EButtonStyle.text,
                    size: M3EButtonSize.sm,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Скачать'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  M3EButton(
                    style: M3EButtonStyle.filled,
                    size: M3EButtonSize.sm,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Войти'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
