import 'package:json_annotation/json_annotation.dart';

import '../utils/template_formatter.dart';

part '../../.gen/settings/domain/path_template.cg.g.dart';

@JsonSerializable()
class PathTemplate {
  final String path;

  static String initialPathPlaceholder =
      '${TemplateFormatter.startTagChar}Серия${TemplateFormatter.endTagChar}-${TemplateFormatter.startTagChar}Номер в серии${TemplateFormatter.endTagChar}';

  PathTemplate({required this.path});

  PathTemplate.initial() : path = initialPathPlaceholder;

  factory PathTemplate.fromJson(Map<String, dynamic> json) =>
      _$PathTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$PathTemplateToJson(this);
}
