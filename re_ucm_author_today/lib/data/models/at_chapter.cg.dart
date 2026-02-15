import 'package:dart_mappable/dart_mappable.dart';

part '../../../.gen/data/models/at_chapter.cg.mapper.dart';

@MappableClass()
class ATChapter with ATChapterMappable {
  final bool isSuccessful;
  final String? title;
  final String? text;
  final String? key;

  ATChapter(this.isSuccessful, this.title, this.text, this.key);

  static ATChapter fromJson(Map<String, dynamic> json) =>
      ATChapterMapper.fromMap(json);
}
