import 'dart:typed_data';
import 'package:dart_book/dart_book.dart';
import 'package:dio/dio.dart';
import 'package:re_ucm_core/logger.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_core/models/progress.dart';

import 'data/litres_api.cg.dart';
import 'data/models/lr_settings.cg.dart';
import 'domain/constants.dart';
import 'domain/utils/download_helper.dart';
import 'domain/utils/metadata_parser.dart';

class LitresService implements PortalService<LRSettings> {
  static const startSidAuthAction = 'start_sid_auth';
  static const loginBySidAction = 'login_by_sid';
  static const loginByWebAction = 'login_by_web';
  static const logoutAction = 'logout';

  final Dio _dio;
  final Map<String, List<BookResource>> _cachedResources = {};
  final Map<String, String> _coverUrls = {};

  LitresService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              headers: {
                'user-agent': userAgentLR,
                'accept':
                    'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
              },
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  @override
  void Function(LRSettings updatedSettings)? onSettingsChanged;

  @override
  LRSettings settingsFromJson(Map<String, dynamic>? json) =>
      json == null ? const LRSettings() : LRSettings.fromJson(json);

  @override
  List<PortalSettingItem> buildSettingsSchema(LRSettings settings) {
    return [
      PortalSettingStateSwitcher<bool>(
        currentState: isAuthorized(settings),
        states: {
          true: PortalSettingActionButton(
            actionId: logoutAction,
            title: 'Выйти',
            subtitle: settings.userLogin != null
                ? 'Вы вошли как ${settings.userLogin}'
                : settings.userId != null
                ? 'Вы вошли как id${settings.userId}'
                : 'Вход выполнен',
            onTap: (s) => _logout(s as LRSettings),
          ),
          false: PortalSettingGroup([
            PortalSettingWebAuthButton(
              actionId: loginByWebAction,
              title: 'Войти через браузер',
              startUrl:
                  '$urlLitres/auth/login/?redirectAfterAuth=%2Fpages%2Fmy_books_fresh%2F',
              successUrl: '$urlLitres/pages/my_books_fresh/',
              cookieName: 'sid',
              userAgent: userAgentLR,
              onCookieObtained: (s, cookie) =>
                  _loginByCookie(s as LRSettings, cookie),
            ),
            PortalSettingStateSwitcher<bool>(
              currentState: settings.sidAuthActive,
              states: {
                true: PortalSettingTextField(
                  actionId: loginBySidAction,
                  title: 'Войти по SID',
                  hint: 'Введите Session ID (sid)',
                  onSubmit: (s, v) => _loginBySid(s as LRSettings, v),
                ),
                false: PortalSettingActionButton(
                  actionId: startSidAuthAction,
                  title: 'Войти по SID',
                  onTap: (s) => _startSidAuth(s as LRSettings),
                ),
              },
            ),
          ]),
        },
      ),
    ];
  }

  Future<LRSettings> _logout(LRSettings settings) async {
    final updated = settings.copyWith(
      sid: null,
      userId: null,
      userLogin: null,
      sidAuthActive: false,
    );
    return updated;
  }

  Future<LRSettings> _startSidAuth(LRSettings settings) async {
    return settings.copyWith(sidAuthActive: true);
  }

  Future<LRSettings> _loginBySid(LRSettings settings, String sid) async {
    final cleanSid = sid.trim();
    if (cleanSid.isEmpty) {
      throw Exception('Пустой SID');
    }

    final api = LitresAPI.create(sid: cleanSid);
    final meRes = await api.getMe();
    final userId = meRes.payload?.data?.id?.toString();
    final userLogin = meRes.payload?.data?.login;

    final updated = settings.copyWith(
      sid: cleanSid,
      userId: userId,
      userLogin: userLogin,
      sidAuthActive: false,
    );
    onSettingsChanged?.call(updated);
    return updated;
  }

  Future<LRSettings> _loginByCookie(LRSettings settings, String cookie) async {
    return _loginBySid(settings, cookie);
  }

  @override
  bool isAuthorized(LRSettings settings) =>
      settings.sid != null &&
      settings.sid!.isNotEmpty &&
      settings.sid != defaultSidLR;

  @override
  String getIdFromUrl(Uri url) {
    final host = url.host.toLowerCase();
    if (!host.contains('litres.ru')) {
      throw ArgumentError('Неверная ссылка LitRes: $url');
    }

    final artParam = url.queryParameters['art'];
    if (artParam != null &&
        artParam.isNotEmpty &&
        int.tryParse(artParam) != null) {
      return artParam;
    }

    final segments = url.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) {
      throw ArgumentError('Неверная ссылка LitRes: $url');
    }

    final lastSegment = segments.last;
    final subparts = lastSegment.split('-');
    final candidate = subparts.last;

    if (int.tryParse(candidate) != null) {
      return candidate;
    }

    for (final seg in segments.reversed) {
      final parts = seg.split('-');
      if (int.tryParse(parts.last) != null) {
        return parts.last;
      }
    }

    throw ArgumentError('Не удалось определить ID книги из ссылки: $url');
  }

  @override
  Future<BookMetadata> getBookMetadata(
    String id, {
    required LRSettings settings,
  }) async {
    final api = LitresAPI.create(sid: settings.sid);
    final res = await api.getArt(id);
    final art = res.payload?.data;
    if (art == null) {
      throw Exception('Книга $id не найдена на LitRes');
    }
    if (art.coverUrl != null && art.coverUrl!.isNotEmpty) {
      _coverUrls[id] = art.coverUrl!.startsWith('http')
          ? art.coverUrl!
          : '$urlLitres${art.coverUrl}';
    }
    return metadataParserLR(art);
  }

  @override
  Future<BookContent> getBookContent(
    String id, {
    required LRSettings settings,
    void Function(Progress progress)? onProgress,
    CancellationToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled == true) {
      return const BookContent(blocks: []);
    }

    onProgress?.call(
      Progress(
        stage: Stages.downloading,
        message: 'Загрузка книги с LitRes...',
      ),
    );

    final sid = settings.sid ?? defaultSidLR;
    Uint8List? bookBytes;

    if (isAuthorized(settings)) {
      bookBytes = await _downloadAuthorizedBook(id, sid: sid);
    }

    if (cancelToken?.isCancelled == true) {
      return const BookContent(blocks: []);
    }

    bookBytes ??= await _downloadFragment(id);

    if (cancelToken?.isCancelled == true) {
      return const BookContent(blocks: []);
    }

    if (bookBytes == null) {
      throw Exception('Не удалось скачать файл книги $id с LitRes');
    }

    onProgress?.call(
      Progress(
        stage: Stages.decrypting,
        message: 'Распаковка и чтение контента...',
      ),
    );

    final decoded = await decodeBookBytes(bookBytes);

    final resources = List<BookResource>.from(decoded.resources);
    final coverId = decoded.metadata.cover?.ref.id;
    final embeddedCover =
        resources.where((r) => r.id == coverId).firstOrNull ??
        resources
            .where((r) => r.id.toLowerCase().contains('cover'))
            .firstOrNull;

    final externalCoverUrl = _coverUrls[id];
    if (embeddedCover != null && externalCoverUrl != null) {
      resources.add(
        BookResource(
          id: externalCoverUrl,
          mediaType: embeddedCover.mediaType,
          bytes: embeddedCover.bytes,
          originalUri: Uri.tryParse(externalCoverUrl),
        ),
      );
    }

    _cachedResources[id] = resources;

    return decoded.content;
  }

  Future<Uint8List?> _downloadAuthorizedBook(
    String artId, {
    required String sid,
  }) async {
    try {
      final api = LitresAPI.create(sid: sid);
      final filesGrouped = await api.getFilesGrouped(artId);
      final groups = filesGrouped.payload?.data ?? [];

      int? targetFileId;
      String? targetExtension;

      for (final group in groups) {
        final fb2Zip = group.files
            .where((f) => f.extension == 'fb2.zip')
            .firstOrNull;
        if (fb2Zip != null) {
          targetFileId = fb2Zip.id;
          targetExtension = 'fb2.zip';
          break;
        }
        final fb2 = group.files.where((f) => f.extension == 'fb2').firstOrNull;
        if (fb2 != null) {
          targetFileId = fb2.id;
          targetExtension = 'fb2';
          break;
        }
        final epub = group.files
            .where((f) => f.extension == 'epub')
            .firstOrNull;
        if (epub != null) {
          targetFileId = epub.id;
          targetExtension = 'epub';
          break;
        }
      }

      final hosts = <String?>[null, 'www.litres.ru'];
      try {
        final me = await api.getMe();
        final subs =
            me.payload?.data?.partnerSubscriptions?.subscriptions ?? [];
        for (final sub in subs) {
          if (sub.isActive == true &&
              sub.host != null &&
              sub.host!.isNotEmpty) {
            hosts.add(sub.host);
          }
        }
      } catch (_) {}

      final paths = [
        'download_book_j',
        'download_book_subscr',
        'download_my_book_j',
      ];

      for (final host in hosts) {
        for (final path in paths) {
          final uri = buildDownloadUri(
            artId: artId,
            path: path,
            sid: sid,
            host: host,
            fileId: targetFileId,
            type: targetExtension ?? 'fb2.zip',
          );

          final bytes = await _tryDownloadBytes(uri);
          if (bytes != null && bytes.length > 200) {
            logger.i('Successfully downloaded book $artId from $uri');
            return bytes;
          }
        }
      }
    } catch (e, trace) {
      logger.w(
        'Failed authorized download for LitRes $artId',
        error: e,
        stackTrace: trace,
      );
    }
    return null;
  }

  Future<Uint8List?> _downloadFragment(String artId) async {
    final urls = [
      Uri.parse('https://catalit.litres.ru/pub/t/$artId.fb2.zip'),
      Uri.parse('https://catalit.litres.ru/pub/t/$artId.epub'),
      Uri.parse('https://catalit.litres.ru/pub/t/$artId.fb3'),
    ];

    for (final uri in urls) {
      final bytes = await _tryDownloadBytes(uri);
      if (bytes != null && bytes.length > 200) {
        logger.i('Successfully downloaded fragment $artId from $uri');
        return bytes;
      }
    }

    return null;
  }

  Future<Uint8List?> _tryDownloadBytes(Uri uri) async {
    try {
      final res = await _dio.get<Uint8List>(
        uri.toString(),
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) => status != null && status == 200,
        ),
      );
      return res.data;
    } catch (_) {
      return null;
    }
  }

  @override
  BookResourceResolver getResourceResolver(LRSettings settings) {
    return (request, {onByteProgress}) async {
      final reqId = request.id;
      final reqSource = request.source;

      for (final resList in _cachedResources.values) {
        for (final res in resList) {
          if (res.id == reqId || (reqSource != null && res.id == reqSource)) {
            return res;
          }
          if (res.originalUri?.toString() == reqId ||
              (reqSource != null && res.originalUri?.toString() == reqSource)) {
            return res;
          }
        }
      }

      // Если это ссылка на обложку LitRes, а у нас есть встроенная обложка из файла
      if (reqId.contains('/cover/') ||
          (reqSource != null && reqSource.contains('/cover/'))) {
        for (final resList in _cachedResources.values) {
          final cover = resList
              .where(
                (r) =>
                    r.id.toLowerCase().contains('cover') ||
                    (r.fileName != null &&
                        r.fileName!.toLowerCase().contains('cover')),
              )
              .firstOrNull;
          if (cover != null) {
            return BookResource(
              id: reqId,
              mediaType: cover.mediaType,
              bytes: cover.bytes,
              originalUri: Uri.tryParse(reqSource ?? reqId),
            );
          }
        }
      }

      final rawUri = reqSource ?? reqId;
      if (rawUri.isEmpty) return null;

      final url = rawUri.startsWith('/') ? '$urlLitres$rawUri' : rawUri;

      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return null;
      }

      try {
        final res = await _dio.get<Uint8List>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {
              'user-agent': userAgentLR,
              'Session-Id': settings.sid ?? defaultSidLR,
              'app-id': '1',
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
            (headerContentType != null &&
                headerContentType.startsWith('image/'))
            ? headerContentType.split(';').first.trim()
            : _guessMediaType(url);

        return BookResource(
          id: reqId,
          mediaType: mediaType,
          bytes: bytes,
          originalUri: Uri.tryParse(url),
        );
      } catch (e, trace) {
        logger.w(
          'Failed to resolve LitRes resource: $url',
          error: e,
          stackTrace: trace,
        );
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
