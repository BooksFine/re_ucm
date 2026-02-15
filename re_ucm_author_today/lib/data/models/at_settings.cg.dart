import 'package:dart_mappable/dart_mappable.dart';
import 'package:re_ucm_core/models/portal.dart';

part '../../../.gen/data/models/at_settings.cg.mapper.dart';

@MappableClass(ignoreNull: true)
class ATSettings with ATSettingsMappable implements PortalSettings {
  const ATSettings({this.token, this.userId, this.tokenAuthActive = false});

  final String? token;
  final String? userId;

  @MappableField(hook: SkipEncodingHook())
  final bool tokenAuthActive;

  static const fromJson = ATSettingsMapper.fromJson;
}

class SkipEncodingHook extends MappingHook {
  const SkipEncodingHook();

  @override
  Object? beforeEncode(Object? value) => null;
}
