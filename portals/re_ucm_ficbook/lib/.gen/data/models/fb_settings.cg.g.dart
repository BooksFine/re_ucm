// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../data/models/fb_settings.cg.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FBSettings _$FBSettingsFromJson(Map<String, dynamic> json) => _FBSettings(
  mirrorUrl: json['mirrorUrl'] as String? ?? defaultMirrorFB,
  maxConcurrentDownloads:
      (json['maxConcurrentDownloads'] as num?)?.toInt() ?? 4,
  token: json['token'] as String?,
);

Map<String, dynamic> _$FBSettingsToJson(_FBSettings instance) =>
    <String, dynamic>{
      'mirrorUrl': instance.mirrorUrl,
      'maxConcurrentDownloads': instance.maxConcurrentDownloads,
      'token': instance.token,
    };
