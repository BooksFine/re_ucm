// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../presentation/at_settings_controller.cg.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ATSettingsController on ATSettingsControllerBase, Store {
  Computed<bool>? _$isAuthorizedComputed;

  @override
  bool get isAuthorized =>
      (_$isAuthorizedComputed ??= Computed<bool>(() => super.isAuthorized,
              name: 'ATSettingsControllerBase.isAuthorized'))
          .value;

  late final _$isTokenAuthActiveAtom = Atom(
      name: 'ATSettingsControllerBase.isTokenAuthActive', context: context);

  @override
  bool get isTokenAuthActive {
    _$isTokenAuthActiveAtom.reportRead();
    return super.isTokenAuthActive;
  }

  @override
  set isTokenAuthActive(bool value) {
    _$isTokenAuthActiveAtom.reportWrite(value, super.isTokenAuthActive, () {
      super.isTokenAuthActive = value;
    });
  }

  late final _$isTokenAuthLoadingAtom = Atom(
      name: 'ATSettingsControllerBase.isTokenAuthLoading', context: context);

  @override
  bool get isTokenAuthLoading {
    _$isTokenAuthLoadingAtom.reportRead();
    return super.isTokenAuthLoading;
  }

  @override
  set isTokenAuthLoading(bool value) {
    _$isTokenAuthLoadingAtom.reportWrite(value, super.isTokenAuthLoading, () {
      super.isTokenAuthLoading = value;
    });
  }

  late final _$tokenAuthAsyncAction =
      AsyncAction('ATSettingsControllerBase.tokenAuth', context: context);

  @override
  Future<dynamic> tokenAuth() {
    return _$tokenAuthAsyncAction.run(() => super.tokenAuth());
  }

  late final _$ATSettingsControllerBaseActionController =
      ActionController(name: 'ATSettingsControllerBase', context: context);

  @override
  void startTokenAuth() {
    final _$actionInfo = _$ATSettingsControllerBaseActionController.startAction(
        name: 'ATSettingsControllerBase.startTokenAuth');
    try {
      return super.startTokenAuth();
    } finally {
      _$ATSettingsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isTokenAuthActive: ${isTokenAuthActive},
isTokenAuthLoading: ${isTokenAuthLoading},
isAuthorized: ${isAuthorized}
    ''';
  }
}
