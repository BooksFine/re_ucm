import 'package:json_annotation/json_annotation.dart';

import '../presentation/widgets/tag_editing_controller.dart';
import 'path_placeholders.dart';

part '../../../.gen/features/settings/domain/path_template.cg.g.dart';

@JsonSerializable()
class PathTemplate {
  final String path;
  final Map<int, PathPlaceholders> placeholders;

  PathTemplate({required this.path, required this.placeholders});

  PathTemplate.initial()
    : path =
          '${TagEditingController.tagSymbol}-${TagEditingController.tagSymbol}',
      placeholders = {
        0: PathPlaceholders.series,
        2: PathPlaceholders.seriesNumber,
      };

  factory PathTemplate.fromJson(Map<String, dynamic> json) =>
      _$PathTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$PathTemplateToJson(this);
}
