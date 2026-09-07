import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/ui/tokens.dart';

class RecentBookContainer extends StatelessWidget {
  const RecentBookContainer({
    super.key,
    required this.isDownloading,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin = const EdgeInsets.symmetric(vertical: 4),
    this.onTap,
  });

  final bool isDownloading;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: isDownloading
              ? cs.primary.withValues(alpha: 0.4)
              : cs.outlineVariant.withValues(alpha: 0.35),
          width: isDownloading ? 1.2 : 0.6,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

String formatDownloadedDate(DateTime date) {
  final now = DateTime.now();
  final isToday =
      now.year == date.year && now.month == date.month && now.day == date.day;
  final timeStr = DateFormat('HH:mm').format(date);
  if (isToday) {
    return 'сегодня в $timeStr';
  }
  final yesterday = now.subtract(const Duration(days: 1));
  final isYesterday =
      yesterday.year == date.year &&
      yesterday.month == date.month &&
      yesterday.day == date.day;
  if (isYesterday) {
    return 'вчера в $timeStr';
  }
  if (now.year == date.year) {
    return DateFormat('d MMM, HH:mm', 'ru').format(date);
  }
  return DateFormat('d MMM yyyy', 'ru').format(date);
}

SaveFormat getEffectiveFormat(RecentBook book, SettingsService settings) {
  return book.saveFormat ?? settings.saveFormat;
}

String? formatSeriesLine(RecentBook book) {
  final name = book.seriesName;
  if (name == null) return null;
  return '$name #${book.seriesNumber ?? 1}';
}
