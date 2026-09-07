import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobx/mobx.dart';

import '../../../../core/di.dart';
import '../../../../core/ui/tokens.dart';
import '../../../../core/ui/widgets/widgets.dart';
import '../common/settings_input_decoration.dart';
import '../settings_controller.cg.dart';

class AuthorsSeparatorCard extends StatefulWidget {
  const AuthorsSeparatorCard({super.key, this.controller});

  final SettingsController? controller;

  @override
  State<AuthorsSeparatorCard> createState() => _AuthorsSeparatorCardState();
}

class _AuthorsSeparatorCardState extends State<AuthorsSeparatorCard> {
  late SettingsController _effectiveController;
  late final TextEditingController _authorsSeparatorController;
  ReactionDisposer? _disposer;

  static const _presets = [
    (', ', 'Запятая ( , )'),
    ('; ', 'Точка с запятой ( ; )'),
  ];

  @override
  void initState() {
    super.initState();
    _authorsSeparatorController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _effectiveController =
        widget.controller ?? AppDependencies.of(context).settingsController;
    if (_authorsSeparatorController.text.isEmpty) {
      _authorsSeparatorController.text =
          _effectiveController.authorsPathSeparator;
    }
    _disposer?.call();
    _disposer = reaction(
      (_) => _effectiveController.authorsPathSeparator,
      (String value) {
        if (_authorsSeparatorController.text != value) {
          _authorsSeparatorController.text = value;
        }
      },
    );
  }

  @override
  void dispose() {
    _disposer?.call();
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
            final current = _effectiveController.authorsPathSeparator;
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
                          alpha: AppOpacity.strong,
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
                      _effectiveController.updateAuthorsPathSeparator(separator);
                    },
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _authorsSeparatorController,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          decoration: settingsInputDecoration(
            context,
            labelText: 'Другой разделитель',
          ),
          onChanged: _effectiveController.updateAuthorsPathSeparator,
        ),
      ],
    );
  }
}
