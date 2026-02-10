// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../data/models/at_chapter.cg.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ATChapter _$ATChapterFromJson(Map<String, dynamic> json) => ATChapter(
      json['isSuccessful'] as bool,
      json['title'] as String?,
      json['text'] as String?,
      json['key'] as String?,
    );

Map<String, dynamic> _$ATChapterToJson(ATChapter instance) => <String, dynamic>{
      'isSuccessful': instance.isSuccessful,
      'title': instance.title,
      'text': instance.text,
      'key': instance.key,
    };
