import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:re_ucm_core/models/portal.dart';

part '../../.gen/data/models/lr_settings.cg.freezed.dart';
part '../../.gen/data/models/lr_settings.cg.g.dart';

@freezed
abstract class LRSettings with _$LRSettings implements PortalSettings {
  const LRSettings._();

  const factory LRSettings({
    String? sid,
    String? userId,
    String? userLogin,
    @Default(false)
    @JsonKey(includeToJson: false, includeFromJson: false)
    bool sidAuthActive,
  }) = _LRSettings;

  factory LRSettings.fromJson(Map<String, dynamic> json) =>
      _$LRSettingsFromJson(json);
}
