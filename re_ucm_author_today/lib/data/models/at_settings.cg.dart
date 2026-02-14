import 'package:json_annotation/json_annotation.dart';
import 'package:re_ucm_core/models/portal.dart';

part '../../.gen/data/models/at_settings.cg.g.dart';

@JsonSerializable()
class ATSettings implements PortalSettings {
  const ATSettings({this.token, this.userId, this.tokenAuthActive = false});

  final String? token;
  final String? userId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool tokenAuthActive;

  //TODO перевести на dart_mappable
  ATSettings copyWith({
    Object? token = _sentinel,
    Object? userId = _sentinel,
    bool? tokenAuthActive,
  }) {
    return ATSettings(
      token: token == _sentinel ? this.token : token as String?,
      userId: userId == _sentinel ? this.userId : userId as String?,
      tokenAuthActive: tokenAuthActive ?? this.tokenAuthActive,
    );
  }

  static const _sentinel = Object();

  factory ATSettings.fromJson(Map<String, dynamic> json) =>
      _$ATSettingsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ATSettingsToJson(this);
}
