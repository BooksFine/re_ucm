import 'package:flutter/services.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/navigation/router.dart';
import '../../../../core/navigation/router_delegate.dart';
import '../../../../core/ui/tokens.dart';

bool _cachedWarnUnauthorized = true;

/// Показывает диалог-предупреждение, если пользователь не авторизован в источнике.
///
/// Возвращает `true`, если пользователь подтвердил скачивание («Всё равно скачать»).
/// Возвращает `false`, если скачивание отменено или пользователь перешёл ко входу.
Future<bool> checkAndConfirmUnauthorizedDownload({
  required BuildContext context,
  required PortalSession session,
  SettingsService? settingsService,
}) async {
  final hasAuthSupport = session.portal.code != 'ficbook';
  final isAuthorized = session.isAuthorized;

  if (!hasAuthSupport || isAuthorized || !_cachedWarnUnauthorized) {
    return true;
  }

  final targetContext = rootNavigationKey.currentContext ?? context;

  final result = await showDialog<bool>(
    context: targetContext,
    barrierDismissible: true,
    builder: (dialogCtx) => _UnauthorizedDownloadDialog(
      session: session,
      onClose: () => Navigator.of(dialogCtx).pop(false),
    ),
  );

  return result ?? false;
}

class _UnauthorizedDownloadDialog extends StatefulWidget {
  const _UnauthorizedDownloadDialog({
    required this.session,
    required this.onClose,
  });

  final PortalSession session;
  final VoidCallback onClose;

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
        constraints: const BoxConstraints(maxWidth: 420),
        child: Stack(
          children: [
            Padding(
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
                  // Верхний бейдж иконки (фирменный янтарно-предупреждающий стиль)
                  Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.account_circle_outlined,
                        size: 28,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Заголовок
                  Text(
                    'Вы не авторизованы',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Описание
                  Text(
                    'Не выполнен вход в «$portalName».\n'
                    'Будут загружены только бесплатные главы.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Инфо-бейдж о закрытых главах
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: AppSpacing.md,
                  //     vertical: AppSpacing.sm,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  //     borderRadius: BorderRadius.circular(AppRadii.md),
                  //     border: Border.all(
                  //       color: cs.outlineVariant.withValues(alpha: 0.35),
                  //       width: 0.8,
                  //     ),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Icon(
                  //         Icons.info_outline_rounded,
                  //         size: 18,
                  //         color: cs.primary,
                  //       ),
                  //       const SizedBox(width: AppSpacing.sm),
                  //       Expanded(
                  //         child: Text(
                  //           'Платные и закрытые части останутся недоступны',
                  //           style: theme.textTheme.bodySmall?.copyWith(
                  //             color: cs.onSurfaceVariant,
                  //             fontWeight: FontWeight.w500,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: AppSpacing.md),

                  // Чекбокс «Больше не спрашивать» с тач-таргетом 48dp
                  Center(
                    child: Material(
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
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Сочетание кнопок: аккуратная пара «Войти» + «Всё равно скачать»
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: M3EButton(
                          style: M3EButtonStyle.tonal,
                          size: M3EButtonSize.md,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop(false);
                            Nav.goSourceDetails(widget.session.portal.code);
                          },
                          child: const Text('Войти'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        flex: 3,
                        child: M3EButton(
                          style: M3EButtonStyle.filled,
                          size: M3EButtonSize.md,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            if (_dontAskAgain) {
                              _cachedWarnUnauthorized = false;
                            }
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Всё равно скачать'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Верхний крестик «Закрыть» без нагромождения третьей кнопки
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Закрыть',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onClose();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
