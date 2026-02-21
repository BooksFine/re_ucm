export '../../.gen/features/changelog/changelog.gen.dart';

class Changelog {
  final String title;
  final String date;
  final String content;
  final String? technicalDetails;

  const Changelog({
    required this.title,
    required this.date,
    required this.content,
    this.technicalDetails,
  });
}
