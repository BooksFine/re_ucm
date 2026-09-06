import 'package:json_annotation/json_annotation.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../portals/portal_factory.dart';
import '../../settings/domain/save_format.dart';

part '../../.gen/recent_books/domain/recent_book.cg.g.dart';

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
  final String? savedFilePath;
  final DateTime? downloadedAt;
  final SaveFormat? saveFormat;

  RecentBook({
    required this.id,
    required this.title,
    required this.authors,
    this.coverUrl,
    this.seriesName,
    this.seriesNumber,
    required this.portal,
    required this.added,
    this.savedFilePath,
    this.downloadedAt,
    this.saveFormat,
  });

  RecentBook copyWith({
    String? id,
    String? title,
    String? authors,
    String? coverUrl,
    String? seriesName,
    int? seriesNumber,
    Portal? portal,
    DateTime? added,
    String? savedFilePath,
    DateTime? downloadedAt,
    SaveFormat? saveFormat,
  }) {
    return RecentBook(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      coverUrl: coverUrl ?? this.coverUrl,
      seriesName: seriesName ?? this.seriesName,
      seriesNumber: seriesNumber ?? this.seriesNumber,
      portal: portal ?? this.portal,
      added: added ?? this.added,
      savedFilePath: savedFilePath ?? this.savedFilePath,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      saveFormat: saveFormat ?? this.saveFormat,
    );
  }

  factory RecentBook.fromJson(Map<String, dynamic> json) =>
      _$RecentBookFromJson(json);

  Map<String, dynamic> toJson() => _$RecentBookToJson(this);
}
