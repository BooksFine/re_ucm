import 'package:json_annotation/json_annotation.dart';

import '../../portals/portal.dart';

part '../../../.gen/features/recent_books/domain/recent_book.cg.g.dart';

@JsonSerializable()
class RecentBook {
  final String id;
  final String title;
  final String authors;
  final String? coverUrl;
  final String? seriesName;
  final int? seriesNumber;
  final Portal portal;
  final DateTime added;

  RecentBook({
    required this.id,
    required this.title,
    required this.authors,
    this.coverUrl,
    this.seriesName,
    this.seriesNumber,
    required this.portal,
    required this.added,
  });

  factory RecentBook.fromJson(Map<String, dynamic> json) =>
      _$RecentBookFromJson(json);
  Map<String, dynamic> toJson() => _$RecentBookToJson(this);

  @override
  bool operator ==(Object other) {
    return other is RecentBook && id == other.id;
  }

  @override
  int get hashCode => (portal.code + id).hashCode;
}
