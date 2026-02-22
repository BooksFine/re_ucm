import 'package:json_annotation/json_annotation.dart';

import '../presentation/widgets/tag_editing_controller.dart';

part '../../../.gen/features/settings/domain/path_template.cg.g.dart';

@JsonSerializable()
class PathTemplate {
  final String path;

  static const String _startTagChar = TagEditingController.startTagChar;
  static const String _endTagChar = TagEditingController.endTagChar;
  static String initialPathPlaceholder =
      '$_startTagCharСерия$_endTagChar-$_startTagCharНомер в серии$_endTagChar';

  PathTemplate({required this.path});

  PathTemplate.initial() : path = initialPathPlaceholder;

  factory PathTemplate.fromJson(Map<String, dynamic> json) =>
      _$PathTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$PathTemplateToJson(this);
}
