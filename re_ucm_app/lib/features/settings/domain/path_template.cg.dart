import 'package:json_annotation/json_annotation.dart';

part '../../../.gen/features/settings/domain/path_template.cg.g.dart';

@JsonSerializable()
class PathTemplate {
  final String path;

  static String initialPathPlaceholder = '%Серия%-%Номер в серии%';

  PathTemplate({required this.path});

  PathTemplate.initial() : path = initialPathPlaceholder;

  factory PathTemplate.fromJson(Map<String, dynamic> json) =>
      _$PathTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$PathTemplateToJson(this);
}
