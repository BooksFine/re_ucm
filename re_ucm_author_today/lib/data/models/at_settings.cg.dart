import 'package:json_annotation/json_annotation.dart';
import 'package:re_ucm_core/models/portal/portal_settings.dart';

part '../../.gen/data/models/at_settings.cg.g.dart';

@JsonSerializable()
class ATSettings implements PortalSettings {
  ATSettings({this.token, this.userId, this.tokenAuthActive = false});

  String? token;
  String? userId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool tokenAuthActive;

  factory ATSettings.fromJson(Map<String, dynamic> json) =>
      _$ATSettingsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ATSettingsToJson(this);
}
