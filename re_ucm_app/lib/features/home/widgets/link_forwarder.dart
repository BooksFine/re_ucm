import 'dart:async';

import 'package:dart_book/dart_book.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/re_ucm_core.dart';

import '../../../core/di.dart';
import '../../../core/navigation/nav.dart';
import '../../../core/ui/tokens.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../common/utils/book_link_parser.dart';
import '../../common/widgets/app_button.dart';
import '../../downloads/presentation/download_modal.dart';
import '../../downloads/presentation/widgets/download_book_header.dart';
import '../../downloads/presentation/widgets/unauthorized_download_dialog.dart';
import 'format_selector.dart';
import 'link_forwarder_controller.dart';

/// Debounce автофетча: быстрый ввод не спамит сеть.
const _autoFetchDebounce = Duration(milliseconds: 450);

class LinkForwarder extends StatefulWidget {
  const LinkForwarder({
    super.key,
    this.isWide = false,
    this.controller,
    this.textController,
  });

  final bool isWide;
  final LinkForwarderController? controller;
  final TextEditingController? textController;

  @override
  State<LinkForwarder> createState() => _LinkForwarderState();
}

class _LinkForwarderState extends State<LinkForwarder> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _textController =
      widget.textController ?? TextEditingController();
  final _focusNode = FocusNode();
  late final LinkForwarderController _controller =
      widget.controller ?? LinkForwarderController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (_textController.text.isNotEmpty) {
      _controller.onTextChanged(_textController.text);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.textController == null) {
      _textController.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _controller.onTextChanged(value);
    // Debounce: фетчим только устоявшийся ввод.
    _debounce?.cancel();
    _debounce = Timer(_autoFetchDebounce, () {
      if (!mounted) return;
      final current = _textController.text;
      final candidate = _controller.autoFetchCandidate(current);
      if (candidate != null) {
        _fetchBookInfo(candidate);
      }
    });
  }

  void _reset() {
    _debounce?.cancel();
    _textController.clear();
    _controller.reset();
  }

  Future<void> _pasteFromClipboard() async {
    _debounce?.cancel();
    HapticFeedback.lightImpact();
    final text = await _controller.readClipboardText();
    if (text == null || !mounted) return;
    // Курсор — в конец вставленного текста.
    _textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
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
    await _controller.fetchBookInfo(
      link: link,
      session: session,
    );
  }

  Future<void> _startDownload() async {
    final deps = AppDependencies.of(context);
    final portal = _controller.loadedPortal;
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
    // Старт — отдельно от pure-сборки таска.
    unawaited(task.start());
    if (mounted) {
      await showDownloadModalForTask(context, task);
    }
    // Очищаем только после модала, а не до подтверждения.
    if (mounted) {
      _textController.clear();
      _controller.reset();
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
            return switch (_controller.state.value) {
              LinkForwarderLoading() => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: LinkPreviewCard(
                    child: DownloadBookHeaderSkeleton(isWide: widget.isWide),
                  ),
                ),
              LinkForwarderError(:final message) => Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.sm,
                    left: 4,
                    right: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          message,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              LinkForwarderLoaded(:final metadata, :final portal) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: LinkPreviewCard(
                    child: _LoadedPreview(
                      controller: _controller,
                      metadata: metadata,
                      portal: portal,
                      isWide: widget.isWide,
                      onDownload: _startDownload,
                    ),
                  ),
                ),
              LinkForwarderIdle() => const SizedBox.shrink(),
            };
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
          if (controller.isLoading) {
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

/// Единая «плашка» превью.
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
  const _LoadedPreview({
    required this.controller,
    required this.metadata,
    required this.portal,
    required this.onDownload,
    this.isWide = false,
  });

  final LinkForwarderController controller;
  final BookMetadata metadata;
  final Portal portal;
  final VoidCallback onDownload;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final deps = AppDependencies.of(context);
    return Observer(
      builder: (_) {
        final currentFormat =
            controller.selectedFormat.value ?? deps.settingsService.saveFormat;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DownloadBookHeader(book: metadata, portal: portal, isWide: isWide),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 380;
                final formatSelector = FormatSelector(
                  current: currentFormat,
                  onSelected: controller.setSelectedFormat,
                );
                final downloadButton = AppButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text(
                    'Скачать',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: formatSelector),
                      const SizedBox(height: AppSpacing.sm),
                      downloadButton,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    formatSelector,
                    downloadButton,
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
