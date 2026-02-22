import 'package:json_annotation/json_annotation.dart';

part '../../.gen/data/models/at_chapter.cg.g.dart';

@JsonSerializable()
class ATChapter {
  final bool isSuccessful;
  final String? title;
  final String? text;
  final String? key;

  ATChapter(this.isSuccessful, this.title, this.text, this.key);

  factory ATChapter.fromJson(Map<String, dynamic> json) =>
      _$ATChapterFromJson(json);

  Map<String, dynamic> toJson() => _$ATChapterToJson(this);
}
