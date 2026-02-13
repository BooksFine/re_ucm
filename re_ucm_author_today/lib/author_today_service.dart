import 'package:re_ucm_author_today/data/models/at_settings.cg.dart';
import 'package:re_ucm_core/models/book.dart';
import 'package:re_ucm_core/models/portal.dart';

import 'data/author_today_api.cg.dart';
import 'data/models/at_chapter.cg.dart';
import 'domain/utils/metadata_parser.dart';
import 'domain/utils/decrypt.dart';

class AuthorTodayService implements PortalService<ATSettings> {
  static const startTokenAuthAction = 'start_token_auth';
  static const loginByTokenAction = 'login_by_token';
  static const loginByWebAction = 'login_by_web';
  static const logoutAction = 'logout';

  AuthorTodayService(this.portal);
  final Portal portal;

  @override
  ATSettings settingsFromJson(Map<String, dynamic>? json) =>
      json == null ? ATSettings() : ATSettings.fromJson(json);

  @override
  List<PortalSettingItem<ATSettings>> buildSettingsSchema(ATSettings settings) {
    final isAuth = isAuthorized(settings);

    return [
      const PortalSettingSectionTitle<ATSettings>('Author.Today'),
      if (isAuth)
        PortalSettingActionButton<ATSettings>(
          actionId: logoutAction,
          title: 'Выйти из аккаунта',
          subtitle: settings.userId == null
              ? null
              : 'Вы залогинены как id${settings.userId}',
          onTap: _logout,
        )
      else ...[
        // PortalSettingWebAuthButton(
        //   actionId: loginByWebAction,
        //   title: 'Вход через web',
        //   onAuthorized: (v, s) async => v,
        //   startUrl: '$urlAT/account/login',
        //   successUrl: '$urlAT/',
        //   cookieName: 'LoginCookie',
        //   userAgent:
        //       'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Mobile Safari/537.36 EdgA/127.0.0.0 $userAgentAT',
        // ),
        if (settings.tokenAuthActive)
          PortalSettingTextField<ATSettings>(
            actionId: loginByTokenAction,
            title: 'Вход с помощью токена',
            hint: 'Вставьте токен',
            onSubmit: _loginByToken,
          )
        else
          PortalSettingActionButton<ATSettings>(
            actionId: startTokenAuthAction,
            title: 'Вход с помощью токена',
            onTap: _startTokenAuth,
          ),
      ],
    ];
  }

  Future<ATSettings> _logout(ATSettings settings) async {
    settings.token = null;
    settings.userId = null;
    settings.tokenAuthActive = false;
    return settings;
  }

  Future<ATSettings> _startTokenAuth(ATSettings settings) async {
    settings.tokenAuthActive = true;
    return settings;
  }

  Future<ATSettings> _loginByToken(ATSettings settings, String token) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      throw Exception('Пустой токен');
    }

    final api = AuthorTodayAPI.create(token: normalizedToken);
    final res = await api.checkUser('Bearer $normalizedToken');
    final userId = res.data['id']?.toString();

    settings.token = normalizedToken;
    settings.tokenAuthActive = false;
    if (userId != null) settings.userId = userId;

    return settings;
  }

  @override
  bool isAuthorized(ATSettings settings) => settings.token != null;

  @override
  String getIdFromUrl(Uri url) {
    if (url.host != 'author.today' ||
        url.pathSegments.length != 2 ||
        !['work', 'reader'].contains(url.pathSegments[0]) ||
        int.tryParse(url.pathSegments[1]) == null) {
      throw ArgumentError('Invalid link');
    }

    return url.pathSegments[1];
  }

  @override
  Future<Book> getBookFromId(String id, {required ATSettings settings}) async {
    final api = AuthorTodayAPI.create(token: settings.token);
    final res = await api.getMeta(id);
    return metadataParserAT(res.data, portal);
  }

  @override
  Future<List<Chapter>> getTextFromId(
    String id, {
    required ATSettings settings,
  }) async {
    final token = settings.token;
    final userId = settings.userId;
    final api = AuthorTodayAPI.create(token: token);
    final res = await api.getManyTexts(id);
    final successfulEntries = res.data.where((entry) => entry.isSuccessful);
    return Future.wait(
      successfulEntries.map((chapter) => _createChapter(chapter, userId)),
    );
  }

  Future<Chapter> _createChapter(ATChapter chapter, String? userId) async {
    return Chapter(
      title: chapter.title!,
      content: await decryptData(chapter.text!, chapter.key!, userId),
    );
  }
}
