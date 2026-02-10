import 'package:flutter_svg/flutter_svg.dart';
import 'package:re_ucm_author_today/author_today_service.dart';
import 'package:re_ucm_author_today/domain/constants.dart';
import 'package:re_ucm_core/models/portal.dart';

class AuthorToday implements Portal {
  static late final PortalService _service;

  @override
  String get code => codeAT;

  @override
  String get name => nameAT;

  @override
  String get url => urlAT;

  @override
  SvgAssetLoader get logo =>
      SvgAssetLoader('assets/logo.svg', packageName: 're_ucm_author_today');

  @override
  PortalService get service => _service;

  AuthorToday._();

  static Future<AuthorToday> create() async {
    final portal = AuthorToday._();
    _service = await AuthorTodayService.create(portal);
    return portal;
  }
}
