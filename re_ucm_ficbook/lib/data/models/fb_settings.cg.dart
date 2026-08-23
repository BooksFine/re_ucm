import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:re_ucm_core/models/portal.dart';
import '../../domain/constants.dart';

part '../../.gen/data/models/fb_settings.cg.freezed.dart';
part '../../.gen/data/models/fb_settings.cg.g.dart';

@freezed
abstract class FBSettings with _$FBSettings implements PortalSettings {
  const FBSettings._();

  const factory FBSettings({
    @Default(defaultMirrorFB) String mirrorUrl,
    @Default(4) int maxConcurrentDownloads,
    String? token,
  }) = _FBSettings;

  factory FBSettings.fromJson(Map<String, dynamic> json) =>
      _$FBSettingsFromJson(json);
}
