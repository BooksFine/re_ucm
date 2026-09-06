// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../data/models/lr_settings.cg.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LRSettings {

 String? get sid; String? get userId; String? get userLogin;@JsonKey(includeToJson: false, includeFromJson: false) bool get sidAuthActive;
/// Create a copy of LRSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LRSettingsCopyWith<LRSettings> get copyWith => _$LRSettingsCopyWithImpl<LRSettings>(this as LRSettings, _$identity);

  /// Serializes this LRSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LRSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LRSettings&&(identical(other.sid, _this.sid) || other.sid == _this.sid)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.userLogin, _this.userLogin) || other.userLogin == _this.userLogin)&&(identical(other.sidAuthActive, _this.sidAuthActive) || other.sidAuthActive == _this.sidAuthActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LRSettings;
  return Object.hash(runtimeType,_this.sid,_this.userId,_this.userLogin,_this.sidAuthActive);
}

@override
String toString() {
  final _this = this as LRSettings;
  return 'LRSettings(sid: ${_this.sid}, userId: ${_this.userId}, userLogin: ${_this.userLogin}, sidAuthActive: ${_this.sidAuthActive})';
}


}

/// @nodoc
abstract mixin class $LRSettingsCopyWith<$Res>  {
  factory $LRSettingsCopyWith(LRSettings value, $Res Function(LRSettings) _then) = _$LRSettingsCopyWithImpl;
@useResult
$Res call({
 String? sid, String? userId, String? userLogin,@JsonKey(includeToJson: false, includeFromJson: false) bool sidAuthActive
});




}
/// @nodoc
class _$LRSettingsCopyWithImpl<$Res>
    implements $LRSettingsCopyWith<$Res> {
  _$LRSettingsCopyWithImpl(this._self, this._then);

  final LRSettings _self;
  final $Res Function(LRSettings) _then;

/// Create a copy of LRSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sid = freezed,Object? userId = freezed,Object? userLogin = freezed,Object? sidAuthActive = null,}) {
  return _then(LRSettings(
sid: freezed == sid ? _self.sid : sid // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,userLogin: freezed == userLogin ? _self.userLogin : userLogin // ignore: cast_nullable_to_non_nullable
as String?,sidAuthActive: null == sidAuthActive ? _self.sidAuthActive : sidAuthActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LRSettings].
extension LRSettingsPatterns on LRSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LRSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LRSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LRSettings value)  $default,){
final _that = this;
switch (_that) {
case _LRSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LRSettings value)?  $default,){
final _that = this;
switch (_that) {
case _LRSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? sid,  String? userId,  String? userLogin, @JsonKey(includeToJson: false, includeFromJson: false)  bool sidAuthActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LRSettings() when $default != null:
return $default(_that.sid,_that.userId,_that.userLogin,_that.sidAuthActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? sid,  String? userId,  String? userLogin, @JsonKey(includeToJson: false, includeFromJson: false)  bool sidAuthActive)  $default,) {final _that = this;
switch (_that) {
case _LRSettings():
return $default(_that.sid,_that.userId,_that.userLogin,_that.sidAuthActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? sid,  String? userId,  String? userLogin, @JsonKey(includeToJson: false, includeFromJson: false)  bool sidAuthActive)?  $default,) {final _that = this;
switch (_that) {
case _LRSettings() when $default != null:
return $default(_that.sid,_that.userId,_that.userLogin,_that.sidAuthActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LRSettings extends LRSettings {
  const _LRSettings({this.sid, this.userId, this.userLogin, @JsonKey(includeToJson: false, includeFromJson: false) this.sidAuthActive = false}): super._();
  factory _LRSettings.fromJson(Map<String, dynamic> json) => _$LRSettingsFromJson(json);

@override final  String? sid;
@override final  String? userId;
@override final  String? userLogin;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  bool sidAuthActive;

/// Create a copy of LRSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LRSettingsCopyWith<_LRSettings> get copyWith => __$LRSettingsCopyWithImpl<_LRSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LRSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LRSettings&&(identical(other.sid, sid) || other.sid == sid)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userLogin, userLogin) || other.userLogin == userLogin)&&(identical(other.sidAuthActive, sidAuthActive) || other.sidAuthActive == sidAuthActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sid,userId,userLogin,sidAuthActive);
}

@override
String toString() {
    return 'LRSettings(sid: $sid, userId: $userId, userLogin: $userLogin, sidAuthActive: $sidAuthActive)';
}


}

/// @nodoc
abstract mixin class _$LRSettingsCopyWith<$Res> implements $LRSettingsCopyWith<$Res> {
  factory _$LRSettingsCopyWith(_LRSettings value, $Res Function(_LRSettings) _then) = __$LRSettingsCopyWithImpl;
@override @useResult
$Res call({
 String? sid, String? userId, String? userLogin,@JsonKey(includeToJson: false, includeFromJson: false) bool sidAuthActive
});




}
/// @nodoc
class __$LRSettingsCopyWithImpl<$Res>
    implements _$LRSettingsCopyWith<$Res> {
  __$LRSettingsCopyWithImpl(this._self, this._then);

  final _LRSettings _self;
  final $Res Function(_LRSettings) _then;

/// Create a copy of LRSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sid = freezed,Object? userId = freezed,Object? userLogin = freezed,Object? sidAuthActive = null,}) {
  return _then(_LRSettings(
sid: freezed == sid ? _self.sid : sid // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,userLogin: freezed == userLogin ? _self.userLogin : userLogin // ignore: cast_nullable_to_non_nullable
as String?,sidAuthActive: null == sidAuthActive ? _self.sidAuthActive : sidAuthActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
