import 'package:json_annotation/json_annotation.dart';

part '../../.gen/data/models/lr_art.cg.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LRArtResponse {
  final int? status;
  final LRArtPayload? payload;

  LRArtResponse({this.status, this.payload});

  factory LRArtResponse.fromJson(Map<String, dynamic> json) =>
      _$LRArtResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LRArtResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRArtPayload {
  final LRArt data;

  LRArtPayload({required this.data});

  factory LRArtPayload.fromJson(Map<String, dynamic> json) =>
      _$LRArtPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$LRArtPayloadToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRArt {
  final int id;
  final String title;
  final String? htmlAnnotation;
  final String? originalHtmlAnnotation;
  final String? coverUrl;
  @JsonKey(defaultValue: [])
  final List<LRPerson> persons;
  @JsonKey(defaultValue: [])
  final List<LRGenre> genres;
  @JsonKey(defaultValue: [])
  final List<LRTag> tags;
  @JsonKey(defaultValue: [])
  final List<LRSeries> series;
  final bool? isFinished;
  final int? symbolsCount;
  final String? languageCode;
  final String? lastUpdatedAt;
  final String? dateWrittenAt;
  final String? publicationDate;
  final int? previewFileId;
  final int? releaseFileId;

  LRArt({
    required this.id,
    required this.title,
    this.htmlAnnotation,
    this.originalHtmlAnnotation,
    this.coverUrl,
    this.persons = const [],
    this.genres = const [],
    this.tags = const [],
    this.series = const [],
    this.isFinished,
    this.symbolsCount,
    this.languageCode,
    this.lastUpdatedAt,
    this.dateWrittenAt,
    this.publicationDate,
    this.previewFileId,
    this.releaseFileId,
  });

  factory LRArt.fromJson(Map<String, dynamic> json) => _$LRArtFromJson(json);
  Map<String, dynamic> toJson() => _$LRArtToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRPerson {
  final dynamic id;
  final String fullName;
  final String? role;
  final String? url;

  LRPerson({required this.id, required this.fullName, this.role, this.url});

  factory LRPerson.fromJson(Map<String, dynamic> json) =>
      _$LRPersonFromJson(json);
  Map<String, dynamic> toJson() => _$LRPersonToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRGenre {
  final int? id;
  final String? name;
  final String? url;

  LRGenre({this.id, this.name, this.url});

  factory LRGenre.fromJson(Map<String, dynamic> json) =>
      _$LRGenreFromJson(json);
  Map<String, dynamic> toJson() => _$LRGenreToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRTag {
  final int? id;
  final String? name;
  final String? url;

  LRTag({this.id, this.name, this.url});

  factory LRTag.fromJson(Map<String, dynamic> json) => _$LRTagFromJson(json);
  Map<String, dynamic> toJson() => _$LRTagToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRSeries {
  final int? id;
  final String? name;
  final String? url;
  final dynamic sequenceNumber;
  final dynamic artOrder;

  LRSeries({this.id, this.name, this.url, this.sequenceNumber, this.artOrder});

  dynamic get number => artOrder ?? sequenceNumber;

  factory LRSeries.fromJson(Map<String, dynamic> json) =>
      _$LRSeriesFromJson(json);
  Map<String, dynamic> toJson() => _$LRSeriesToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRFilesGroupedResponse {
  final int? status;
  final LRFilesGroupedPayload? payload;

  LRFilesGroupedResponse({this.status, this.payload});

  factory LRFilesGroupedResponse.fromJson(Map<String, dynamic> json) =>
      _$LRFilesGroupedResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LRFilesGroupedResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRFilesGroupedPayload {
  @JsonKey(defaultValue: [])
  final List<LRFileGroup> data;

  LRFilesGroupedPayload({this.data = const []});

  factory LRFilesGroupedPayload.fromJson(Map<String, dynamic> json) =>
      _$LRFilesGroupedPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$LRFilesGroupedPayloadToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRFileGroup {
  final String? fileType;
  @JsonKey(defaultValue: [])
  final List<LRFileItem> files;

  LRFileGroup({this.fileType, this.files = const []});

  factory LRFileGroup.fromJson(Map<String, dynamic> json) =>
      _$LRFileGroupFromJson(json);
  Map<String, dynamic> toJson() => _$LRFileGroupToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRFileItem {
  final int id;
  final String? filename;
  final String? extension;
  final String? mime;
  final int? size;

  LRFileItem({
    required this.id,
    this.filename,
    this.extension,
    this.mime,
    this.size,
  });

  factory LRFileItem.fromJson(Map<String, dynamic> json) =>
      _$LRFileItemFromJson(json);
  Map<String, dynamic> toJson() => _$LRFileItemToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRMeResponse {
  final int? status;
  final LRMePayload? payload;

  LRMeResponse({this.status, this.payload});

  factory LRMeResponse.fromJson(Map<String, dynamic> json) =>
      _$LRMeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LRMeResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRMePayload {
  final LRMeData? data;

  LRMePayload({this.data});

  factory LRMePayload.fromJson(Map<String, dynamic> json) =>
      _$LRMePayloadFromJson(json);
  Map<String, dynamic> toJson() => _$LRMePayloadToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRMeData {
  final int? id;
  final String? login;
  final LRPartnerSubscriptions? partnerSubscriptions;

  LRMeData({this.id, this.login, this.partnerSubscriptions});

  factory LRMeData.fromJson(Map<String, dynamic> json) =>
      _$LRMeDataFromJson(json);
  Map<String, dynamic> toJson() => _$LRMeDataToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRPartnerSubscriptions {
  final List<LRSubscription>? subscriptions;

  LRPartnerSubscriptions({this.subscriptions});

  factory LRPartnerSubscriptions.fromJson(Map<String, dynamic> json) =>
      _$LRPartnerSubscriptionsFromJson(json);
  Map<String, dynamic> toJson() => _$LRPartnerSubscriptionsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRSubscription {
  final bool? isActive;
  final String? host;
  final String? type;

  LRSubscription({this.isActive, this.host, this.type});

  factory LRSubscription.fromJson(Map<String, dynamic> json) =>
      _$LRSubscriptionFromJson(json);
  Map<String, dynamic> toJson() => _$LRSubscriptionToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRAuthResponse {
  final LRAuthPayload? payload;
  final String? error;

  LRAuthResponse({this.payload, this.error});

  factory LRAuthResponse.fromJson(Map<String, dynamic> json) =>
      _$LRAuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LRAuthResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRAuthPayload {
  final LRAuthData? data;

  LRAuthPayload({this.data});

  factory LRAuthPayload.fromJson(Map<String, dynamic> json) =>
      _$LRAuthPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$LRAuthPayloadToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LRAuthData {
  final String? sid;

  LRAuthData({this.sid});

  factory LRAuthData.fromJson(Map<String, dynamic> json) =>
      _$LRAuthDataFromJson(json);
  Map<String, dynamic> toJson() => _$LRAuthDataToJson(this);
}
