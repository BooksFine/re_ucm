import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobx/mobx.dart';

import '../../../../core/ui/tokens.dart';
import '../../../../core/ui/widgets/widgets.dart';
import '../common/settings_input_decoration.dart';
import '../settings_controller.cg.dart';

class AuthorsSeparatorCard extends StatefulWidget {
  const AuthorsSeparatorCard({super.key, required this.controller});

  final SettingsController controller;

  @override
  State<AuthorsSeparatorCard> createState() => _AuthorsSeparatorCardState();
}

class _AuthorsSeparatorCardState extends State<AuthorsSeparatorCard> {
  late final TextEditingController _authorsSeparatorController;
  late final ReactionDisposer _disposer;

  static const _presets = [
    (', ', 'Запятая ( , )'),
    ('; ', 'Точка с запятой ( ; )'),
  ];

  @override
  void initState() {
    super.initState();
    _authorsSeparatorController =
        TextEditingController(text: widget.controller.authorsPathSeparator);
    _disposer = reaction(
      (_) => widget.controller.authorsPathSeparator,
      (String value) {
        if (_authorsSeparatorController.text != value) {
          _authorsSeparatorController.text = value;
        }
      },
    );
  }

  @override
  void dispose() {
    _disposer();
    _authorsSeparatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      icon: Icons.people_alt_rounded,
      titleWidget: AppCardTitle.text('Разделитель авторов'),
      subtitleWidget: const AppCardSubtitle(
        text: 'Символ между несколькими авторами',
      ),
      children: [
        Observer(
          builder: (_) {
            final current = widget.controller.authorsPathSeparator;
            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final (separator, label) in _presets)
                  FilterChip(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    selected: current == separator,
                    label: Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onSelected: (_) {
                      _authorsSeparatorController.text = separator;
                      widget.controller.updateAuthorsPathSeparator(separator);
                    },
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _authorsSeparatorController,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          decoration: settingsInputDecoration(
            context,
            labelText: 'Другой разделитель',
          ),
          onChanged: widget.controller.updateAuthorsPathSeparator,
        ),
      ],
    );
  }
}
