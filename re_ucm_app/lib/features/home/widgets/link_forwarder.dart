import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/ui/tokens.dart';
import '../../common/utils/uri_from_url.dart';
import '../../downloads/presentation/download_modal.dart';
import '../../downloads/presentation/widgets/download_book_header.dart';
import 'link_forwarder_controller.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.bindContext(context);
  }

  @override
  void dispose() {
    _controller.unbindContext();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _controller.onTextChanged(value);
  }

  void _reset() {
    _textController.clear();
    _onChanged('');
    _controller.reset();
  }

  Future<void> _pasteFromClipboard() async {
    await _controller.pasteFromClipboard(
      onPasted: (text) async {
        _textController.text = text;
        _onChanged(text);
        _focusNode.requestFocus();
      },
    );
  }

  Future<void> _fetchBookInfo() async {
    _focusNode.unfocus();
    await _controller.fetchBookInfo(
      text: _textController.text.trim(),
      validate: () => _formKey.currentState?.validate() ?? false,
    );
  }

  Future<void> _startDownload() async {
    final settingsService = AppDependencies.of(context).settingsService;
    await _controller.startDownload(
      defaultFormat: settingsService.saveFormat,
      showModal: (task) => showDownloadModalForTask(context, task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final settingsService = AppDependencies.of(context).settingsService;

    return Observer(
      builder: (context) {
        final currentFormat =
            _controller.selectedFormat.value ?? settingsService.saveFormat;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                focusNode: _focusNode,
                controller: _textController,
                textInputAction: TextInputAction.go,
                onFieldSubmitted: (_) => _fetchBookInfo(),
                onChanged: _onChanged,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Вставьте ссылку на книгу...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  prefixIcon: Icon(
                    Icons.link_rounded,
                    color: cs.primary,
                    size: 22,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_controller.isLoadingBook.value)
                        Padding(
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
                        )
                      else if (!_controller.isEmpty.value)
                        IconButton(
                          tooltip: 'Очистить',
                          icon: Icon(
                            Icons.clear_rounded,
                            color: cs.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: _reset,
                        )
                      else
                        IconButton(
                          tooltip: 'Вставить из буфера',
                          icon: Icon(
                            Icons.content_paste_rounded,
                            color: cs.primary,
                            size: 20,
                          ),
                          onPressed: _pasteFromClipboard,
                        ),
                    ],
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHigh,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    borderSide: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    borderSide: BorderSide(
                      color: cs.primary,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    borderSide: BorderSide(
                      color: cs.error,
                      width: 1.2,
                    ),
                  ),
                ),
                validator: (url) {
                  if (url == null || url.trim().isEmpty) {
                    return 'Введите или вставьте ссылку';
                  }
                  try {
                    final uri = uriFromUrl(url.trim());
                    PortalFactory.fromUrl(uri).service.getIdFromUrl(uri);
                    return null;
                  } catch (e) {
                    return 'Неподдерживаемая ссылка на книгу';
                  }
                },
              ),
            ),

            if (_controller.isLoadingBook.value) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.35),
                    width: 0.6,
                  ),
                ),
                child: const DownloadBookHeaderSkeleton(isWide: false),
              ),
            ],

            if (_controller.loadingError.value != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 16, color: cs.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _controller.loadingError.value!,
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_controller.loadedMetadata.value != null && _controller.loadedPortal.value != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.35),
                    width: 0.6,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DownloadBookHeader(
                      book: _controller.loadedMetadata.value!,
                      portal: _controller.loadedPortal.value!,
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
                                      _controller.setSelectedFormat(fmt);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                        M3EButton.icon(
                          onPressed: _startDownload,
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text(
                            'Скачать',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
