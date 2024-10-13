// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../data/models/at_work_metadata.cg.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ATWorkMetadata _$ATWorkMetadataFromJson(Map<String, dynamic> json) =>
    ATWorkMetadata(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      annotation: json['annotation'] as String?,
      authorNotes: json['authorNotes'] as String?,
      coverUrl: json['coverUrl'] as String?,
      lastUpdateTime: DateTime.parse(json['lastUpdateTime'] as String),
      isFinished: json['isFinished'] as bool,
      textLength: (json['textLength'] as num).toInt(),
      authorFIO: json['authorFIO'] as String,
      authorUserName: json['authorUserName'] as String,
      coAuthorId: (json['coAuthorId'] as num?)?.toInt(),
      coAuthorFIO: json['coAuthorFIO'] as String?,
      coAuthorUserName: json['coAuthorUserName'] as String?,
      secondCoAuthorId: (json['secondCoAuthorId'] as num?)?.toInt(),
      secondCoAuthorFIO: json['secondCoAuthorFIO'] as String?,
      secondCoAuthorUserName: json['secondCoAuthorUserName'] as String?,
      genreId: (json['genreId'] as num).toInt(),
      firstSubGenreId: (json['firstSubGenreId'] as num?)?.toInt(),
      secondSubGenreId: (json['secondSubGenreId'] as num?)?.toInt(),
      seriesId: (json['seriesId'] as num?)?.toInt(),
      seriesOrder: (json['seriesOrder'] as num?)?.toInt(),
      seriesTitle: json['seriesTitle'] as String?,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ATWorkMetadataToJson(ATWorkMetadata instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'annotation': instance.annotation,
      'authorNotes': instance.authorNotes,
      'coverUrl': instance.coverUrl,
      'lastUpdateTime': instance.lastUpdateTime.toIso8601String(),
      'isFinished': instance.isFinished,
      'textLength': instance.textLength,
      'authorFIO': instance.authorFIO,
      'authorUserName': instance.authorUserName,
      'coAuthorId': instance.coAuthorId,
      'coAuthorFIO': instance.coAuthorFIO,
      'coAuthorUserName': instance.coAuthorUserName,
      'secondCoAuthorId': instance.secondCoAuthorId,
      'secondCoAuthorFIO': instance.secondCoAuthorFIO,
      'secondCoAuthorUserName': instance.secondCoAuthorUserName,
      'genreId': instance.genreId,
      'firstSubGenreId': instance.firstSubGenreId,
      'secondSubGenreId': instance.secondSubGenreId,
      'seriesId': instance.seriesId,
      'seriesOrder': instance.seriesOrder,
      'seriesTitle': instance.seriesTitle,
      'tags': instance.tags,
    };
