import 'package:intl/intl.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

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
