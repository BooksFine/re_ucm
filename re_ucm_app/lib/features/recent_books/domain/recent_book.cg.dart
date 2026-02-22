import 'package:json_annotation/json_annotation.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../portals/domain/portal_factory.dart';

part '../../../.gen/features/recent_books/domain/recent_book.cg.g.dart';

@JsonSerializable()
class RecentBook {
  final String id;
  final String title;
  final String authors;
  final String? coverUrl;
  final String? seriesName;
  final int? seriesNumber;
  @JsonKey(fromJson: PortalFactory.fromJson, toJson: PortalFactory.toJson)
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
}
