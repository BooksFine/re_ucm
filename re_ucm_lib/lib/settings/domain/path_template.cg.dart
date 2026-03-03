import 'package:freezed_annotation/freezed_annotation.dart';

import 'template_formatter.dart';

part '../../.gen/settings/domain/path_template.cg.freezed.dart';
part '../../.gen/settings/domain/path_template.cg.g.dart';

@freezed
@JsonSerializable()
class PathTemplate with _$PathTemplate {
  PathTemplate({required this.path, required this.seriesPath});

  @override
  final String path;
  @override
  final String seriesPath;

  static String initialPathPlaceholder =
      '${TemplateFormatter.startTagChar}Название${TemplateFormatter.endTagChar}';

  static String initialSeriesPathPlaceholder =
      '${TemplateFormatter.startTagChar}Серия${TemplateFormatter.endTagChar} — ${TemplateFormatter.startTagChar}Номер в серии${TemplateFormatter.endTagChar}';

  factory PathTemplate.initial() => PathTemplate(
    path: initialPathPlaceholder,
    seriesPath: initialSeriesPathPlaceholder,
  );

  factory PathTemplate.fromJson(Map<String, dynamic> json) =>
      _$PathTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$PathTemplateToJson(this);
}
