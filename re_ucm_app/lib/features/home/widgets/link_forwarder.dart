import 'package:dart_book/dart_book.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/re_ucm_core.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/ui/tokens.dart';
import '../../common/utils/uri_from_url.dart';
import '../../downloads/presentation/download_modal.dart';
import '../../downloads/presentation/widgets/download_book_header.dart';
import '../../downloads/presentation/widgets/unauthorized_download_dialog.dart';

class LinkForwarder extends StatefulWidget {
  const LinkForwarder({super.key});

  @override
  State<LinkForwarder> createState() => _LinkForwarderState();
}

class _LinkForwarderState extends State<LinkForwarder> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isEmpty = true;
  SaveFormat? _selectedFormat;

  bool _isLoadingBook = false;
  String? _loadingError;
  BookMetadata? _loadedMetadata;
  Portal? _loadedPortal;
  String? _loadedBookId;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final newIsEmpty = value.trim().isEmpty;
    if (_isEmpty != newIsEmpty) {
      setState(() => _isEmpty = newIsEmpty);
    }
    // If text changed, reset previously loaded preview
    if (_loadedMetadata != null || _loadingError != null) {
      setState(() {
        _loadedMetadata = null;
        _loadedPortal = null;
        _loadedBookId = null;
        _loadingError = null;
      });
    }
    _checkAndAutoFetch(value);
  }

  void _checkAndAutoFetch(String value) {
    final text = value.trim();
    if (text.isEmpty || _isLoadingBook) return;
    try {
      final uri = uriFromUrl(text);
      final portal = PortalFactory.fromUrl(uri);
      final bookId = portal.service.getIdFromUrl(uri);
      if (bookId.isNotEmpty && bookId != _loadedBookId) {
        _fetchBookInfo();
      }
    } catch (_) {
      // Not a supported portal URL yet
    }
  }

  void _reset() {
    _textController.clear();
    _onChanged('');
    setState(() {
      _isLoadingBook = false;
      _loadingError = null;
      _loadedMetadata = null;
      _loadedPortal = null;
      _loadedBookId = null;
    });
  }

  Future<void> _pasteFromClipboard() async {
    HapticFeedback.lightImpact();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isNotEmpty) {
      _textController.text = text;
      _onChanged(text);
      _focusNode.requestFocus();
      _fetchBookInfo();
    }
  }

  Future<void> _fetchBookInfo() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final url = _textController.text.trim();
    final uri = uriFromUrl(url);
    final portal = PortalFactory.fromUrl(uri);
    final bookId = portal.service.getIdFromUrl(uri);

    _focusNode.unfocus();
    setState(() {
      _isLoadingBook = true;
      _loadingError = null;
      _loadedMetadata = null;
      _loadedPortal = null;
      _loadedBookId = null;
    });

    try {
      final deps = AppDependencies.of(context);
      final session = deps.settingsService.sessionByCode(portal.code);
      final meta = await session.getBookMetadata(bookId);

      if (!mounted) return;
      setState(() {
        _isLoadingBook = false;
        _loadedMetadata = meta;
        _loadedPortal = portal;
        _loadedBookId = bookId;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingBook = false;
        _loadingError = 'Не удалось загрузить данные книги: $e';
      });
    }
  }

  Future<void> _startDownload() async {
    if (_loadedMetadata == null || _loadedPortal == null || _loadedBookId == null) {
      return;
    }

    final deps = AppDependencies.of(context);
    final session = deps.settingsService.sessionByCode(_loadedPortal!.code);

    final shouldProceed = await checkAndConfirmUnauthorizedDownload(
      context: context,
      session: session,
      settingsService: deps.settingsService,
    );
    if (!shouldProceed || !mounted) return;

    final format = _selectedFormat ?? deps.settingsService.saveFormat;

    final task = deps.downloadsService.getOrCreateTask(
      session: session,
      bookId: _loadedBookId!,
      initialMetadata: _loadedMetadata,
    );
    task.updateSaveFormat(format);
    if (!task.isActive) {
      task.start();
    }

    _reset();

    if (mounted) {
      showDownloadModalForTask(context, task);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final settingsService = AppDependencies.of(context).settingsService;

    return Observer(
      builder: (context) {
        final currentFormat = _selectedFormat ?? settingsService.saveFormat;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search / Link Input Bar
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
                      if (_isLoadingBook)
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
                      else if (!_isEmpty)
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

            // Loading skeleton while book info is fetching
            if (_isLoadingBook) ...[
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

            // Error message if fetch failed
            if (_loadingError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 16, color: cs.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _loadingError!,
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Loaded Book Card & Format + Download Button
            if (_loadedMetadata != null && _loadedPortal != null) ...[
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
                      book: _loadedMetadata!,
                      portal: _loadedPortal!,
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
                        // Quick format chips
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
                                      HapticFeedback.selectionClick();
                                      setState(() => _selectedFormat = fmt);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Action: Download Button
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
