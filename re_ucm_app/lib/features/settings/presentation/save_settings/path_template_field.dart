import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../common/settings_input_decoration.dart';
import 'placeholder_button.dart';
import 'tag_editing_controller.dart';

class PathTemplateField extends StatefulWidget {
  const PathTemplateField({
    super.key,
    required this.initialPath,
    required this.onChanged,
    required this.title,
    this.placeholders = PathPlaceholders.values,
  });

  final String initialPath;
  final ValueChanged<String> onChanged;
  final String title;
  final List<PathPlaceholders> placeholders;

  @override
  State<PathTemplateField> createState() => _PathTemplateFieldState();
}

class _PathTemplateFieldState extends State<PathTemplateField> {
  late TagEditingController pathController;
  final FocusNode focus = FocusNode();
  final ScrollController scrollController = ScrollController();

  late String path = widget.initialPath;
  late bool isPathEmpty;
  String? pathError;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    pathController = TagEditingController(text: widget.initialPath);
    isPathEmpty = pathController.text.isEmpty;
  }

  void _savePath() {
    if (pathError != null) {
      pathController.text = path;
      pathError = null;
      isPathEmpty = path.isEmpty;
    } else {
      if (isPathEmpty) {
        pathController.text = path;
      } else if (pathController.text != path) {
        path = pathController.text;
        widget.onChanged(path);
      }
    }
    isEditing = false;
  }

  @override
  void didUpdateWidget(covariant PathTemplateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPath != oldWidget.initialPath && !isEditing) {
      pathController.text = widget.initialPath;
      path = widget.initialPath;
      isPathEmpty = widget.initialPath.isEmpty;
    }
  }

  @override
  void dispose() {
    pathController.dispose();
    focus.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void onPathChanged(String value) {
    final newIsEmpty = value.isEmpty;
    final hasIllegal = TemplateFormatter.illegalChars.hasMatch(value);

    final newError = hasIllegal ? 'Недопустимые символы: <>:"/\\|?*' : null;

    if (isPathEmpty != newIsEmpty || pathError != newError) {
      isPathEmpty = newIsEmpty;
      pathError = newError;
      setState(() {});
    }
  }

  void onPathSaved() {
    if (pathError != null) return;
    _savePath();
    focus.unfocus();
    setState(() {});
  }

  double _calculateCursorX(String text, int targetOffset, TextStyle style) {
    double totalWidth = 0.0;
    int currentPos = 0;
    final matches = TagEditingController.tagRegExp.allMatches(text);

    for (final match in matches) {
      if (match.start >= targetOffset) break;

      if (match.start > currentPos) {
        final end = math.min(match.start, targetOffset);
        final plainText = text.substring(currentPos, end);
        final painter = TextPainter(
          text: TextSpan(text: plainText, style: style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        totalWidth += painter.width;
        if (end == targetOffset) return totalWidth;
      }

      final tagLabel = match.group(1) ?? '';
      final tagPainter = TextPainter(
        text: TextSpan(
          text: tagLabel,
          style: style.copyWith(fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      totalWidth += tagPainter.width + 3.0;

      currentPos = match.end;
      if (match.end >= targetOffset) return totalWidth;
    }

    if (currentPos < targetOffset && currentPos < text.length) {
      final plainText = text.substring(currentPos, targetOffset);
      final painter = TextPainter(
        text: TextSpan(text: plainText, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      totalWidth += painter.width;
    }

    return totalWidth;
  }

  void _scrollToCaret(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;

      final theme = Theme.of(context);
      final style = theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ) ??
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);

      final offset = pathController.selection.isValid
          ? pathController.selection.extentOffset
          : pathController.text.length;

      final cursorX = _calculateCursorX(pathController.text, offset, style);

      final currentOffset = scrollController.offset;
      final viewportWidth = scrollController.position.viewportDimension;
      const margin = 28.0;

      double? targetOffset;
      if (cursorX + margin > currentOffset + viewportWidth) {
        targetOffset = cursorX + margin - viewportWidth;
      } else if (cursorX - margin < currentOffset) {
        targetOffset = cursorX - margin;
      }

      if (targetOffset != null) {
        final clamped = targetOffset.clamp(
          0.0,
          scrollController.position.maxScrollExtent,
        );
        scrollController.animateTo(
          clamped,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void insertTemplateTag(String tag) {
    pathController.insertTag(tag);
    onPathChanged(pathController.text);
    focus.requestFocus();
    _scrollToCaret(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFieldTapRegion(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            readOnly: !isEditing,
            scrollPadding: EdgeInsets.zero,
            controller: pathController,
            focusNode: focus,
            scrollController: scrollController,
            maxLines: 1,
            onTap: () {
              if (!isEditing) {
                setState(() => isEditing = true);
                focus.requestFocus();
              }
            },
            onChanged: onPathChanged,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
            decoration: settingsInputDecoration(
              context,
              labelText: widget.title,
              errorText: pathError,
              isEditing: isEditing,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEditing) ...[
                      if (!isPathEmpty)
                        ExcludeFocus(
                          child: IconButton(
                            padding: .zero,
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            tooltip: 'Очистить',
                            onPressed: () {
                              pathController.clear();
                              onPathChanged('');
                              focus.requestFocus();
                            },
                          ),
                        ),
                      ExcludeFocus(
                        child: IconButton(
                          icon: Icon(
                            Icons.check_circle_rounded,
                            size: 22,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          tooltip: 'Применить',
                          onPressed: onPathSaved,
                        ),
                      ),
                    ] else
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Редактировать',
                        onPressed: () {
                          setState(() => isEditing = true);
                          focus.requestFocus();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: Durations.short4,
            alignment: Alignment.topCenter,
            child: isEditing
                ? ExcludeFocus(
                    child: Container(
                      width: double.infinity,
                      color: Colors.transparent,
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 6),
                            child: Text(
                              'Доступные переменные (нажмите для вставки):',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final tag in widget.placeholders)
                                PlaceholderButton(
                                  title: tag.label,
                                  onTap: () => insertTemplateTag(tag.label),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
