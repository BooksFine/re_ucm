import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:re_ucm_core/models/portal.dart';

part '../../.gen/data/models/at_settings.cg.freezed.dart';
part '../../.gen/data/models/at_settings.cg.g.dart';

@freezed
abstract class ATSettings with _$ATSettings implements PortalSettings {
  const ATSettings._();

  const factory ATSettings({
    String? token,
    String? userId,
    @Default(false)
    @JsonKey(includeToJson: false, includeFromJson: false)
    bool tokenAuthActive,
  }) = _ATSettings;

  factory ATSettings.fromJson(Map<String, dynamic> json) =>
      _$ATSettingsFromJson(json);

  @override
  Map<String, dynamic> toMap() => toJson();
}
