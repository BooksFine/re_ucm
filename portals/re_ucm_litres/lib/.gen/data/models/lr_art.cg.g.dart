// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../data/models/lr_art.cg.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LRArtResponse _$LRArtResponseFromJson(Map<String, dynamic> json) =>
    LRArtResponse(
      status: (json['status'] as num?)?.toInt(),
      payload: json['payload'] == null
          ? null
          : LRArtPayload.fromJson(json['payload'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LRArtResponseToJson(LRArtResponse instance) =>
    <String, dynamic>{'status': instance.status, 'payload': instance.payload};

LRArtPayload _$LRArtPayloadFromJson(Map<String, dynamic> json) =>
    LRArtPayload(data: LRArt.fromJson(json['data'] as Map<String, dynamic>));

Map<String, dynamic> _$LRArtPayloadToJson(LRArtPayload instance) =>
    <String, dynamic>{'data': instance.data};

LRArt _$LRArtFromJson(Map<String, dynamic> json) => LRArt(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  htmlAnnotation: json['html_annotation'] as String?,
  originalHtmlAnnotation: json['original_html_annotation'] as String?,
  coverUrl: json['cover_url'] as String?,
  persons:
      (json['persons'] as List<dynamic>?)
          ?.map((e) => LRPerson.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  genres:
      (json['genres'] as List<dynamic>?)
          ?.map((e) => LRGenre.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => LRTag.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  series:
      (json['series'] as List<dynamic>?)
          ?.map((e) => LRSeries.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  isFinished: json['is_finished'] as bool?,
  symbolsCount: (json['symbols_count'] as num?)?.toInt(),
  languageCode: json['language_code'] as String?,
  lastUpdatedAt: json['last_updated_at'] as String?,
  dateWrittenAt: json['date_written_at'] as String?,
  publicationDate: json['publication_date'] as String?,
  previewFileId: (json['preview_file_id'] as num?)?.toInt(),
  releaseFileId: (json['release_file_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$LRArtToJson(LRArt instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'html_annotation': instance.htmlAnnotation,
  'original_html_annotation': instance.originalHtmlAnnotation,
  'cover_url': instance.coverUrl,
  'persons': instance.persons,
  'genres': instance.genres,
  'tags': instance.tags,
  'series': instance.series,
  'is_finished': instance.isFinished,
  'symbols_count': instance.symbolsCount,
  'language_code': instance.languageCode,
  'last_updated_at': instance.lastUpdatedAt,
  'date_written_at': instance.dateWrittenAt,
  'publication_date': instance.publicationDate,
  'preview_file_id': instance.previewFileId,
  'release_file_id': instance.releaseFileId,
};

LRPerson _$LRPersonFromJson(Map<String, dynamic> json) => LRPerson(
  id: json['id'],
  fullName: json['full_name'] as String,
  role: json['role'] as String?,
  url: json['url'] as String?,
);

Map<String, dynamic> _$LRPersonToJson(LRPerson instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'role': instance.role,
  'url': instance.url,
};

LRGenre _$LRGenreFromJson(Map<String, dynamic> json) => LRGenre(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  url: json['url'] as String?,
);

Map<String, dynamic> _$LRGenreToJson(LRGenre instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'url': instance.url,
};

LRTag _$LRTagFromJson(Map<String, dynamic> json) => LRTag(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  url: json['url'] as String?,
);

Map<String, dynamic> _$LRTagToJson(LRTag instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'url': instance.url,
};

LRSeries _$LRSeriesFromJson(Map<String, dynamic> json) => LRSeries(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  url: json['url'] as String?,
  sequenceNumber: json['sequence_number'],
  artOrder: json['art_order'],
);

Map<String, dynamic> _$LRSeriesToJson(LRSeries instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'url': instance.url,
  'sequence_number': instance.sequenceNumber,
  'art_order': instance.artOrder,
};

LRFilesGroupedResponse _$LRFilesGroupedResponseFromJson(
  Map<String, dynamic> json,
) => LRFilesGroupedResponse(
  status: (json['status'] as num?)?.toInt(),
  payload: json['payload'] == null
      ? null
      : LRFilesGroupedPayload.fromJson(json['payload'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LRFilesGroupedResponseToJson(
  LRFilesGroupedResponse instance,
) => <String, dynamic>{'status': instance.status, 'payload': instance.payload};

LRFilesGroupedPayload _$LRFilesGroupedPayloadFromJson(
  Map<String, dynamic> json,
) => LRFilesGroupedPayload(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => LRFileGroup.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$LRFilesGroupedPayloadToJson(
  LRFilesGroupedPayload instance,
) => <String, dynamic>{'data': instance.data};

LRFileGroup _$LRFileGroupFromJson(Map<String, dynamic> json) => LRFileGroup(
  fileType: json['file_type'] as String?,
  files:
      (json['files'] as List<dynamic>?)
          ?.map((e) => LRFileItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$LRFileGroupToJson(LRFileGroup instance) =>
    <String, dynamic>{'file_type': instance.fileType, 'files': instance.files};

LRFileItem _$LRFileItemFromJson(Map<String, dynamic> json) => LRFileItem(
  id: (json['id'] as num).toInt(),
  filename: json['filename'] as String?,
  extension: json['extension'] as String?,
  mime: json['mime'] as String?,
  size: (json['size'] as num?)?.toInt(),
);

Map<String, dynamic> _$LRFileItemToJson(LRFileItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filename': instance.filename,
      'extension': instance.extension,
      'mime': instance.mime,
      'size': instance.size,
    };

LRMeResponse _$LRMeResponseFromJson(Map<String, dynamic> json) => LRMeResponse(
  status: (json['status'] as num?)?.toInt(),
  payload: json['payload'] == null
      ? null
      : LRMePayload.fromJson(json['payload'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LRMeResponseToJson(LRMeResponse instance) =>
    <String, dynamic>{'status': instance.status, 'payload': instance.payload};

LRMePayload _$LRMePayloadFromJson(Map<String, dynamic> json) => LRMePayload(
  data: json['data'] == null
      ? null
      : LRMeData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LRMePayloadToJson(LRMePayload instance) =>
    <String, dynamic>{'data': instance.data};

LRMeData _$LRMeDataFromJson(Map<String, dynamic> json) => LRMeData(
  id: (json['id'] as num?)?.toInt(),
  login: json['login'] as String?,
  partnerSubscriptions: json['partner_subscriptions'] == null
      ? null
      : LRPartnerSubscriptions.fromJson(
          json['partner_subscriptions'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$LRMeDataToJson(LRMeData instance) => <String, dynamic>{
  'id': instance.id,
  'login': instance.login,
  'partner_subscriptions': instance.partnerSubscriptions,
};

LRPartnerSubscriptions _$LRPartnerSubscriptionsFromJson(
  Map<String, dynamic> json,
) => LRPartnerSubscriptions(
  subscriptions: (json['subscriptions'] as List<dynamic>?)
      ?.map((e) => LRSubscription.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LRPartnerSubscriptionsToJson(
  LRPartnerSubscriptions instance,
) => <String, dynamic>{'subscriptions': instance.subscriptions};

LRSubscription _$LRSubscriptionFromJson(Map<String, dynamic> json) =>
    LRSubscription(
      isActive: json['is_active'] as bool?,
      host: json['host'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$LRSubscriptionToJson(LRSubscription instance) =>
    <String, dynamic>{
      'is_active': instance.isActive,
      'host': instance.host,
      'type': instance.type,
    };

LRAuthResponse _$LRAuthResponseFromJson(Map<String, dynamic> json) =>
    LRAuthResponse(
      payload: json['payload'] == null
          ? null
          : LRAuthPayload.fromJson(json['payload'] as Map<String, dynamic>),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$LRAuthResponseToJson(LRAuthResponse instance) =>
    <String, dynamic>{'payload': instance.payload, 'error': instance.error};

LRAuthPayload _$LRAuthPayloadFromJson(Map<String, dynamic> json) =>
    LRAuthPayload(
      data: json['data'] == null
          ? null
          : LRAuthData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LRAuthPayloadToJson(LRAuthPayload instance) =>
    <String, dynamic>{'data': instance.data};

LRAuthData _$LRAuthDataFromJson(Map<String, dynamic> json) =>
    LRAuthData(sid: json['sid'] as String?);

Map<String, dynamic> _$LRAuthDataToJson(LRAuthData instance) =>
    <String, dynamic>{'sid': instance.sid};
