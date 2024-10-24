import 'package:json_annotation/json_annotation.dart';

part '../../.gen/data/models/at_work_metadata.cg.g.dart';

@JsonSerializable()
class ATWorkMetadata {
  final int id;
  final String title;
  final String? annotation;
  final String? authorNotes;
  final String? coverUrl;
  final DateTime lastUpdateTime;
  final bool isFinished;
  final int textLength;
  final String authorFIO;
  final String authorUserName;
  final int? coAuthorId;
  final String? coAuthorFIO;
  final String? coAuthorUserName;
  final int? secondCoAuthorId;
  final String? secondCoAuthorFIO;
  final String? secondCoAuthorUserName;

  final int genreId;
  final int? firstSubGenreId;
  final int? secondSubGenreId;
  final int? seriesId;
  final String? seriesTitle;
  final int? seriesWorkNumber;
  final List<String> tags;

  ATWorkMetadata({
    required this.id,
    required this.title,
    this.annotation,
    this.authorNotes,
    required this.coverUrl,
    required this.lastUpdateTime,
    required this.isFinished,
    required this.textLength,
    required this.authorFIO,
    required this.authorUserName,
    this.coAuthorId,
    this.coAuthorFIO,
    this.coAuthorUserName,
    this.secondCoAuthorId,
    this.secondCoAuthorFIO,
    this.secondCoAuthorUserName,
    required this.genreId,
    this.firstSubGenreId,
    this.secondSubGenreId,
    this.seriesId,
    this.seriesWorkNumber,
    this.seriesTitle,
    required this.tags,
  });

  factory ATWorkMetadata.fromJson(Map<String, dynamic> json) =>
      _$ATWorkMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$ATWorkMetadataToJson(this);
}
