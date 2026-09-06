import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/navigation/router_delegate.dart';
import '../../../core/ui/tokens.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../downloads/presentation/download_modal.dart';
import '../../downloads/presentation/widgets/download_book_header.dart';
import '../../downloads/presentation/widgets/unauthorized_download_dialog.dart';
import 'link_forwarder_controller.dart';
import 'link_parser.dart';

class LinkForwarder extends StatefulWidget {
  const LinkForwarder({super.key});

  @override
  State<LinkForwarder> createState() => _LinkForwarderState();
}

class _LinkForwarderState extends State<LinkForwarder> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _controller = LinkForwarderController();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _controller.onTextChanged(value);
    final candidate = _controller.autoFetchCandidate(value);
    if (candidate != null) {
      _fetchBookInfo(candidate);
    }
  }

  void _reset() {
    _textController.clear();
    _controller.reset();
  }

  Future<void> _pasteFromClipboard() async {
    HapticFeedback.lightImpact();
    final text = await _controller.readClipboardText();
    if (text == null || !mounted) return;
    _textController.text = text;
    _controller.onTextChanged(text);
    _focusNode.requestFocus();
    final candidate = tryParseBookLink(text);
    if (candidate != null) {
      await _fetchBookInfo(candidate);
    }
  }

  Future<void> _fetchBookInfo([ParsedBookLink? preset]) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final link = preset ?? tryParseBookLink(_textController.text.trim());
    if (link == null || !mounted) return;
    _focusNode.unfocus();
    final session = AppDependencies.of(
      context,
    ).settingsService.sessionByCode(link.portal.code);
    await _controller.fetchBookInfo(link: link, session: session);
  }

  Future<void> _startDownload() async {
    final deps = AppDependencies.of(context);
    final portal = _controller.loadedPortal.value;
    if (portal == null) return;
    final session = deps.settingsService.sessionByCode(portal.code);

    final shouldProceed = await checkAndConfirmUnauthorizedDownload(
      context: context,
      session: session,
      settingsService: deps.settingsService,
      onLogin: () => Nav.goSourceDetails(portal.code),
    );
    if (!shouldProceed || !mounted) return;

    final task = _controller.buildDownloadTask(
      settingsService: deps.settingsService,
      downloadsService: deps.downloadsService,
    );
    if (task == null || !mounted) return;
    _controller.reset();
    _textController.clear();
    if (mounted) {
      await showDownloadModalForTask(context, task);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          key: _formKey,
          child: _LinkInputField(
            textController: _textController,
            focusNode: _focusNode,
            controller: _controller,
            onChanged: _onChanged,
            onSubmitted: () => _fetchBookInfo(),
            onReset: _reset,
            onPaste: _pasteFromClipboard,
          ),
        ),
        Observer(
          builder: (_) {
            if (_controller.isLoadingBook.value) {
              return const Padding(
                padding: EdgeInsets.only(top: AppSpacing.md),
                child: LinkPreviewCard(
                  child: DownloadBookHeaderSkeleton(isWide: false),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Observer(
          builder: (_) {
            final error = _controller.loadingError.value;
            if (error == null) return const SizedBox.shrink();
            final theme = Theme.of(context);
            final cs = theme.colorScheme;
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: cs.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        error,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Observer(
          builder: (_) {
            final meta = _controller.loadedMetadata.value;
            final portal = _controller.loadedPortal.value;
            if (meta == null || portal == null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: LinkPreviewCard(
                child: _LoadedPreview(
                  controller: _controller,
                  onDownload: _startDownload,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Поле ввода ссылки. Observer точечно вокруг suffix — само поле
/// не перестраивается от статуса загрузки.
class _LinkInputField extends StatelessWidget {
  const _LinkInputField({
    required this.textController,
    required this.focusNode,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onReset,
    required this.onPaste,
  });

  final TextEditingController textController;
  final FocusNode focusNode;
  final LinkForwarderController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onReset;
  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppTextField(
      focusNode: focusNode,
      controller: textController,
      textInputAction: TextInputAction.go,
      onFieldSubmitted: (_) => onSubmitted(),
      onChanged: onChanged,
      hint: 'Вставьте ссылку на книгу...',
      prefixIcon: const Icon(Icons.link_rounded, size: 22),
      suffixIcon: Observer(
        builder: (_) {
          if (controller.isLoadingBook.value) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: 18,
                height: 18,
                child: M3ECircularWavyProgressIndicator(
                  size: 18,
                  strokeWidth: 2,
                  color: cs.primary,
                ),
              ),
            );
          }
          if (!controller.isEmpty.value) {
            return IconButton(
              tooltip: 'Очистить',
              icon: const Icon(Icons.clear_rounded, size: 20),
              onPressed: onReset,
            );
          }
          return IconButton(
            tooltip: 'Вставить из буфера',
            icon: const Icon(Icons.content_paste_rounded, size: 20),
            onPressed: onPaste,
          );
        },
      ),
      validator: (url) {
        if (url == null || url.trim().isEmpty) {
          return 'Введите или вставьте ссылку';
        }
        return tryParseBookLink(url.trim()) == null
            ? 'Неподдерживаемая ссылка на книгу'
            : null;
      },
    );
  }
}

/// Единая «плашка» превью. Раньше одинаковый Container был
/// скопирован дважды в одном файле.
class LinkPreviewCard extends StatelessWidget {
  const LinkPreviewCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
          width: 0.6,
        ),
      ),
      child: child,
    );
  }
}

class _LoadedPreview extends StatelessWidget {
  const _LoadedPreview({required this.controller, required this.onDownload});

  final LinkForwarderController controller;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final deps = AppDependencies.of(context);
    return Observer(
      builder: (_) {
        final currentFormat =
            controller.selectedFormat.value ?? deps.settingsService.saveFormat;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DownloadBookHeader(
              book: controller.loadedMetadata.value!,
              portal: controller.loadedPortal.value!,
              isWide: false,
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Формат: ',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    for (final fmt in [
                      SaveFormat.epub,
                      SaveFormat.fb2,
                      SaveFormat.fb2Zip,
                    ]) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: ChoiceChip(
                          label: Text(fmt.label.toUpperCase()),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: fmt == currentFormat
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          selected: fmt == currentFormat,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.full),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              controller.setSelectedFormat(fmt);
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                M3EButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text(
                    'Скачать',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
