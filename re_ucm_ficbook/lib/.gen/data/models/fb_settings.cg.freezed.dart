// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../data/models/fb_settings.cg.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FBSettings {

 String get mirrorUrl; int get maxConcurrentDownloads; String? get token;
/// Create a copy of FBSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FBSettingsCopyWith<FBSettings> get copyWith => _$FBSettingsCopyWithImpl<FBSettings>(this as FBSettings, _$identity);

  /// Serializes this FBSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FBSettings&&(identical(other.mirrorUrl, mirrorUrl) || other.mirrorUrl == mirrorUrl)&&(identical(other.maxConcurrentDownloads, maxConcurrentDownloads) || other.maxConcurrentDownloads == maxConcurrentDownloads)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mirrorUrl,maxConcurrentDownloads,token);

@override
String toString() {
  return 'FBSettings(mirrorUrl: $mirrorUrl, maxConcurrentDownloads: $maxConcurrentDownloads, token: $token)';
}


}

/// @nodoc
abstract mixin class $FBSettingsCopyWith<$Res>  {
  factory $FBSettingsCopyWith(FBSettings value, $Res Function(FBSettings) _then) = _$FBSettingsCopyWithImpl;
@useResult
$Res call({
 String mirrorUrl, int maxConcurrentDownloads, String? token
});




}
/// @nodoc
class _$FBSettingsCopyWithImpl<$Res>
    implements $FBSettingsCopyWith<$Res> {
  _$FBSettingsCopyWithImpl(this._self, this._then);

  final FBSettings _self;
  final $Res Function(FBSettings) _then;

/// Create a copy of FBSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mirrorUrl = null,Object? maxConcurrentDownloads = null,Object? token = freezed,}) {
  return _then(_self.copyWith(
mirrorUrl: null == mirrorUrl ? _self.mirrorUrl : mirrorUrl // ignore: cast_nullable_to_non_nullable
as String,maxConcurrentDownloads: null == maxConcurrentDownloads ? _self.maxConcurrentDownloads : maxConcurrentDownloads // ignore: cast_nullable_to_non_nullable
as int,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FBSettings].
extension FBSettingsPatterns on FBSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FBSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FBSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FBSettings value)  $default,){
final _that = this;
switch (_that) {
case _FBSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FBSettings value)?  $default,){
final _that = this;
switch (_that) {
case _FBSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mirrorUrl,  int maxConcurrentDownloads,  String? token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FBSettings() when $default != null:
return $default(_that.mirrorUrl,_that.maxConcurrentDownloads,_that.token);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mirrorUrl,  int maxConcurrentDownloads,  String? token)  $default,) {final _that = this;
switch (_that) {
case _FBSettings():
return $default(_that.mirrorUrl,_that.maxConcurrentDownloads,_that.token);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mirrorUrl,  int maxConcurrentDownloads,  String? token)?  $default,) {final _that = this;
switch (_that) {
case _FBSettings() when $default != null:
return $default(_that.mirrorUrl,_that.maxConcurrentDownloads,_that.token);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FBSettings extends FBSettings {
  const _FBSettings({this.mirrorUrl = defaultMirrorFB, this.maxConcurrentDownloads = 4, this.token}): super._();
  factory _FBSettings.fromJson(Map<String, dynamic> json) => _$FBSettingsFromJson(json);

@override@JsonKey() final  String mirrorUrl;
@override@JsonKey() final  int maxConcurrentDownloads;
@override final  String? token;

/// Create a copy of FBSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FBSettingsCopyWith<_FBSettings> get copyWith => __$FBSettingsCopyWithImpl<_FBSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FBSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FBSettings&&(identical(other.mirrorUrl, mirrorUrl) || other.mirrorUrl == mirrorUrl)&&(identical(other.maxConcurrentDownloads, maxConcurrentDownloads) || other.maxConcurrentDownloads == maxConcurrentDownloads)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mirrorUrl,maxConcurrentDownloads,token);

@override
String toString() {
  return 'FBSettings(mirrorUrl: $mirrorUrl, maxConcurrentDownloads: $maxConcurrentDownloads, token: $token)';
}


}

/// @nodoc
abstract mixin class _$FBSettingsCopyWith<$Res> implements $FBSettingsCopyWith<$Res> {
  factory _$FBSettingsCopyWith(_FBSettings value, $Res Function(_FBSettings) _then) = __$FBSettingsCopyWithImpl;
@override @useResult
$Res call({
 String mirrorUrl, int maxConcurrentDownloads, String? token
});




}
/// @nodoc
class __$FBSettingsCopyWithImpl<$Res>
    implements _$FBSettingsCopyWith<$Res> {
  __$FBSettingsCopyWithImpl(this._self, this._then);

  final _FBSettings _self;
  final $Res Function(_FBSettings) _then;

/// Create a copy of FBSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mirrorUrl = null,Object? maxConcurrentDownloads = null,Object? token = freezed,}) {
  return _then(_FBSettings(
mirrorUrl: null == mirrorUrl ? _self.mirrorUrl : mirrorUrl // ignore: cast_nullable_to_non_nullable
as String,maxConcurrentDownloads: null == maxConcurrentDownloads ? _self.maxConcurrentDownloads : maxConcurrentDownloads // ignore: cast_nullable_to_non_nullable
as int,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
