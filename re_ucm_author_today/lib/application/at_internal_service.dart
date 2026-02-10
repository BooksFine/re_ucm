import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/logger.dart';
import 'package:re_ucm_core/models/book.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../data/author_today_api.cg.dart';
import '../data/author_today_storage.dart';
import '../data/models/at_chapter.cg.dart';
import '../domain/constants.dart';
import '../domain/utils/decrypt.dart';
import '../domain/utils/metadata_parser.dart';

class ATInternalService {
  ATInternalService._();
  late final Portal portal;

  static Future<ATInternalService> init(Portal portal) async {
    var service = ATInternalService._();
    service.portal = portal;
    service._storage = await ATStorageSembast.init();
    service.userId = await service._storage.getUserId();
    service.token = await service._storage.getToken();
    service._api = AuthorTodayAPI.create(service: service);
    return service;
  }

  final Observable<String?> _token = Observable(null);
  String? get token => _token.value;
  set token(String? token) => runInAction(() => _token.value = token);

  String? userId;
  late final AuthorTodayAPI _api;
  late final AuthorTodayStorage _storage;

  Future _saveAuthData() async {
    await _storage.setUserId(userId!);
    await _storage.setToken(token!);
  }

  Future login() async {
    CookieManager cookieManager = CookieManager.instance();
    Cookie? cookie = await cookieManager.getCookie(
      url: WebUri(urlAT),
      name: "LoginCookie",
    );

    logger.i('[AuthorToday] Cookies authorization attempt');
    logger.d(cookie);

    if (cookie == null) throw Exception('No login cookies found');

    var res = await _api.login('${cookie.name}=${cookie.value}');
    userId = res.data!['userId'].toString();
    token = res.data!['token'];
    await _saveAuthData();

    logger.i('[AuthorToday] Login successful');
  }

  Future relogin() async {
    logger.i('[AuthorToday] Relogin attempt');
    var res = await _api.refreshToken();
    token = res.data['token'];
    await _storage.setToken(token!);
  }

  Future loginByToken(String newToken) async {
    var res = await _api.checkUser('Bearer $newToken');
    userId = res.data['id'].toString();
    token = newToken;
    await _saveAuthData();
  }

  void logout() {
    CookieManager cookieManager = CookieManager.instance();
    cookieManager.deleteCookies(url: WebUri(urlAT));

    token = null;
    userId = null;
    _storage.clear();
  }

  Future<Book> getMeta(String id) async {
    var res = await _api.getMeta(id);
    return metadataParserAT(res.data, portal);
  }

  Future<List<Chapter>> getManyTexts(String id) async {
    var res = await _api.getManyTexts(id);
    var successfulEntries = res.data.where((e) => e.isSuccessful);
    var chapters = await Future.wait(successfulEntries.map(_createChapter));

    return chapters;
  }

  Future<Chapter> _createChapter(ATChapter chapter) async {
    return Chapter(
      title: chapter.title!,
      content: await decryptData(chapter.text!, chapter.key!, userId),
    );
  }
}
