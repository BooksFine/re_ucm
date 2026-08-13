import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dart_book/dart_book.dart';
import 'package:re_ucm_author_today/data/models/at_settings.cg.dart';
import 'package:re_ucm_core/logger.dart';
import 'package:re_ucm_core/models/portal.dart';

import 'data/author_today_api.cg.dart';
import 'data/models/at_chapter.cg.dart';
import 'domain/constants.dart';
import 'domain/utils/metadata_parser.dart';
import 'domain/utils/decrypt.dart';

class AuthorTodayService implements PortalService<ATSettings> {
  static const startTokenAuthAction = 'start_token_auth';
  static const loginByTokenAction = 'login_by_token';
  static const loginByWebAction = 'login_by_web';
  static const logoutAction = 'logout';

  AuthorTodayService();

  @override
  void Function(ATSettings updatedSettings)? onSettingsChanged;

  @override
  ATSettings settingsFromJson(Map<String, dynamic>? json) =>
      json == null ? ATSettings() : ATSettings.fromJson(json);

  @override
  List<PortalSettingItem> buildSettingsSchema(ATSettings settings) {
    return [
      const PortalSettingSectionTitle('Author.Today'),
      PortalSettingStateSwitcher<bool>(
        currentState: isAuthorized(settings),
        states: {
          true: PortalSettingActionButton(
            actionId: logoutAction,
            title: 'Выйти из аккаунта',
            subtitle: settings.userId == null
                ? null
                : 'Вы залогинены как id${settings.userId}',
            onTap: (s) => _logout(s as ATSettings),
          ),
          false: PortalSettingGroup([
            PortalSettingWebAuthButton(
              actionId: loginByWebAction,
              title: 'Вход через web',
              startUrl: '$urlAT/account/login',
              successUrl: '$urlAT/',
              cookieName: 'LoginCookie',
              userAgent:
                  'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Mobile Safari/537.36 EdgA/127.0.0.0 $userAgentAT',
              onCookieObtained: (s, cookie) =>
                  _loginByCookie(s as ATSettings, cookie),
            ),
            PortalSettingStateSwitcher<bool>(
              currentState: settings.tokenAuthActive,
              states: {
                true: PortalSettingTextField(
                  actionId: loginByTokenAction,
                  title: 'Вход с помощью токена',
                  hint: 'Вставьте токен',
                  onSubmit: (s, v) => _loginByToken(s as ATSettings, v),
                ),
                false: PortalSettingActionButton(
                  actionId: startTokenAuthAction,
                  title: 'Вход с помощью токена',
                  onTap: (s) => _startTokenAuth(s as ATSettings),
                ),
              },
            ),
          ]),
        },
      ),
    ];
  }

  Future<ATSettings> _logout(ATSettings settings) async {
    return settings.copyWith(token: null, userId: null, tokenAuthActive: false);
  }

  Future<ATSettings> _startTokenAuth(ATSettings settings) async {
    return settings.copyWith(tokenAuthActive: true);
  }

  Future<ATSettings> _loginByToken(ATSettings settings, String token) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      throw Exception('Пустой токен');
    }

    final api = AuthorTodayAPI.create(token: normalizedToken);
    final res = await api.checkUser('Bearer $normalizedToken');
    final userId = res.data['id']?.toString();

    return settings.copyWith(
      token: normalizedToken,
      tokenAuthActive: false,
      userId: userId,
    );
  }

  Future<ATSettings> _loginByCookie(ATSettings settings, String cookie) async {
    final api = AuthorTodayAPI.create();
    final res = await api.login('LoginCookie=$cookie');

    final String? token;
    if (res.data is String) {
      token = (res.data as String?)?.trim();
    } else if (res.data is Map) {
      token = (res.data as Map)['token']?.toString();
    } else {
      throw Exception('Неожиданный формат ответа');
    }

    if (token == null || token.isEmpty) {
      throw Exception('Не удалось получить токен');
    }

    final userApi = AuthorTodayAPI.create(token: token);
    final userRes = await userApi.checkUser('Bearer $token');
    final userId = userRes.data['id']?.toString();

    return settings.copyWith(
      token: token,
      tokenAuthActive: false,
      userId: userId,
    );
  }

  Future<String?> _relogin(ATSettings settings) async {
    final token = settings.token;
    if (token == null) return null;

    try {
      final api = AuthorTodayAPI.create(token: token);
      final res = await api.refreshToken();
      final newToken = res.data['token']?.toString();
      if (newToken != null && newToken.isNotEmpty) {
        onSettingsChanged?.call(settings.copyWith(token: newToken));
        return newToken;
      }
    } catch (e, trace) {
      logger.w('Failed to refresh AuthorToday token', error: e, stackTrace: trace);
    }
    return null;
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
  Future<BookMetadata> getBookMetadata(
    String id, {
    required ATSettings settings,
  }) async {
    final api = AuthorTodayAPI.create(
      token: settings.token,
      onRelogin: () => _relogin(settings),
    );
    final res = await api.getMeta(id);
    return metadataParserAT(res.data);
  }

  @override
  Future<BookContent> getBookContent(
    String id, {
    required ATSettings settings,
  }) async {
    final token = settings.token;
    final userId = settings.userId;
    final api = AuthorTodayAPI.create(
      token: token,
      onRelogin: () => _relogin(settings),
    );
    final res = await api.getManyTexts(id);
    final successfulEntries = res.data.where((entry) => entry.isSuccessful);
    final sections = await Future.wait(
      successfulEntries.map((chapter) => _createSection(chapter, userId)),
    );
    return BookContent(blocks: sections);
  }

  Future<BookSection> _createSection(ATChapter chapter, String? userId) async {
    final text = await decryptData(chapter.text!, chapter.key!, userId);
    final blocks = HtmlParser().parseFromString(text);

    return BookSection(
      title: chapter.title != null ? [BookText(chapter.title!)] : const [],
      blocks: blocks,
    );
  }

  @override
  BookResourceResolver getResourceResolver(ATSettings settings) {
    final dio = Dio();
    return (request, {onByteProgress}) async {
      final rawUri = request.source ?? request.id;
      final url = rawUri.startsWith('/') ? '$urlAT$rawUri' : rawUri;

      try {
        final res = await dio.get<Uint8List>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {
              'user-agent': userAgentAT,
              if (settings.token != null)
                'authorization': 'Bearer ${settings.token}',
            },
          ),
          onReceiveProgress: (received, total) {
            onByteProgress?.call(received, total > 0 ? total : null);
          },
        );

        final bytes = res.data;
        if (bytes == null) return null;

        final headerContentType = res.headers.value('content-type');
        final mediaType =
            (headerContentType != null && headerContentType.startsWith('image/'))
                ? headerContentType.split(';').first.trim()
                : _guessMediaType(url);

        return BookResource(
          id: request.id,
          mediaType: mediaType,
          bytes: bytes,
          originalUri: Uri.tryParse(url),
        );
      } catch (e, trace) {
        logger.w('Failed to resolve AuthorToday resource: $url', error: e, stackTrace: trace);
        return null;
      }
    };
  }

  static String _guessMediaType(String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.svg')) return 'image/svg+xml';
    return 'image/jpeg';
  }
}
