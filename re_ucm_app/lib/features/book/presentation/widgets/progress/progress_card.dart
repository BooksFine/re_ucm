import 'package:flutter/material.dart';
import '../../../../../core/ui/constants.dart';

class ProgressCard<T> extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.title,
    this.current,
    this.total,
    this.message,
    required this.items,
    required this.itemBuilder,
    this.borderColor,
  });

  final String title;
  final int? current;
  final int? total;
  final String? message;
  final Color? borderColor;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cur = current ?? 0;
    final tot = total ?? 0;
    final double? progressVal = (tot > 0) ? (cur / tot).clamp(0.0, 1.0) : null;
    final statusText =
        tot > 0 ? '$cur из $tot' : (message ?? 'Инициализация...');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: appPadding * 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(
          color: borderColor ?? theme.colorScheme.primary,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(appPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(statusText, style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: appPadding),
            LinearProgressIndicator(
              borderRadius: BorderRadius.circular(90),
              value: progressVal,
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: appPadding * 2),
              const Divider(height: 1),
              const SizedBox(height: appPadding),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  primary: false,
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: appPadding),
                  itemBuilder: (context, index) =>
                      itemBuilder(context, items[index]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
