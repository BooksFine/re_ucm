import 'package:dart_mappable/dart_mappable.dart';

part '../../../.gen/features/settings/domain/path_template.cg.mapper.dart';

@MappableClass()
class PathTemplate with PathTemplateMappable {
  final String path;

  static String initialPathPlaceholder = '%Серия%-%Номер в серии%';

  PathTemplate({required this.path});

  PathTemplate.initial() : path = initialPathPlaceholder;

  static const fromJson = PathTemplateMapper.fromJson;
}
