import 'package:freezed_annotation/freezed_annotation.dart';

import 'path_placeholders.dart';
import 'template_formatter.dart';

part '../../.gen/settings/domain/path_template.cg.freezed.dart';
part '../../.gen/settings/domain/path_template.cg.g.dart';

@freezed
abstract class PathTemplate with _$PathTemplate {
  const PathTemplate._();

  const factory PathTemplate({
    required String path,
    required String seriesPath,
  }) = _PathTemplate;

  static String initialPathPlaceholder =
      '${TemplateFormatter.startTagChar}${PathPlaceholders.name.label}${TemplateFormatter.endTagChar}';

  static String initialSeriesPathPlaceholder =
      '${TemplateFormatter.startTagChar}${PathPlaceholders.series.label}${TemplateFormatter.endTagChar} — ${TemplateFormatter.startTagChar}${PathPlaceholders.seriesNumber.label}${TemplateFormatter.endTagChar}';

  factory PathTemplate.initial() => PathTemplate(
    path: initialPathPlaceholder,
    seriesPath: initialSeriesPathPlaceholder,
  );

  factory PathTemplate.fromJson(Map<String, dynamic> json) =>
      _$PathTemplateFromJson(json);
}
