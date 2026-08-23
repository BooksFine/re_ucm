import 'dart:typed_data';
import 'package:dart_book/dart_book.dart';
import 'package:dio/dio.dart';
import 'package:re_ucm_core/logger.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_core/models/progress.dart';

import 'data/models/fb_settings.cg.dart';
import 'domain/constants.dart';
import 'domain/utils/content_parser.dart';
import 'domain/utils/metadata_parser.dart';

class FicbookService implements PortalService<FBSettings> {
  static const changeMirrorAction = 'change_mirror';
  static const resetMirrorAction = 'reset_mirror';

  final Dio _dio;

  FicbookService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                headers: {
                  'user-agent': userAgentFB,
                  'accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                  'accept-language': 'ru',
                },
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  @override
  void Function(FBSettings updatedSettings)? onSettingsChanged;

  @override
  FBSettings settingsFromJson(Map<String, dynamic>? json) =>
      json == null ? const FBSettings() : FBSettings.fromJson(json);

  @override
  List<PortalSettingItem> buildSettingsSchema(FBSettings settings) {
    return [
      const PortalSettingSectionTitle('Ficbook (Книга Фанфиков)'),
      PortalSettingGroup([
        PortalSettingTextField(
          actionId: changeMirrorAction,
          title: 'Зеркало сайта',
          hint: settings.mirrorUrl == defaultMirrorFB
              ? defaultMirrorFB
              : 'Текущее: ${settings.mirrorUrl}',
          onSubmit: (s, value) async {
            final mirror =
                value.trim().isEmpty ? defaultMirrorFB : value.trim();
            final updated = (s as FBSettings).copyWith(mirrorUrl: mirror);
            onSettingsChanged?.call(updated);
            return updated;
          },
        ),
        PortalSettingNumberField(
          actionId: 'change_concurrent',
          title: 'Количество параллельных потоков',
          subtitle: 'Одновременная загрузка глав (от 1 до 20)',
          value: settings.maxConcurrentDownloads,
          min: 1,
          max: 20,
          onChanged: (s, value) async {
            final clamped = value.clamp(1, 20);
            final updated =
                (s as FBSettings).copyWith(maxConcurrentDownloads: clamped);
            onSettingsChanged?.call(updated);
            return updated;
          },
        ),
      ]),
    ];
  }

  @override
  bool isAuthorized(FBSettings settings) => true;

  @override
  String getIdFromUrl(Uri url) {
    final host = url.host.toLowerCase();
    if (!host.contains('ficbook.net') &&
        !host.contains('fanficlets.xyz') &&
        !host.contains('ficbook')) {
      throw ArgumentError('Неверная ссылка Ficbook: $url');
    }

    final segments = url.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) {
      throw ArgumentError('Неверная ссылка Ficbook: $url');
    }

    if (segments[0] == 'readfic') {
      if (segments.length >= 2) {
        return segments[1];
      }
      throw ArgumentError('ID фанфика не найден в ссылке: $url');
    }

    // Direct ID in first segment if any
    return segments[0];
  }

  @override
  Future<BookMetadata> getBookMetadata(
    String id, {
    required FBSettings settings,
  }) async {
    final mirror = _normalizeUrl(settings.mirrorUrl);
    final targetUrl = '$mirror/readfic/$id';

    final res = await _dio.get<String>(
      targetUrl,
      options: Options(
        responseType: ResponseType.plain,
        headers: {
          'user-agent': userAgentFB,
        },
      ),
    );

    final html = res.data ?? '';
    return metadataParserFB(html, id, Uri.parse(mirror));
  }

  @override
  Future<BookContent> getBookContent(
    String id, {
    required FBSettings settings,
    void Function(Progress progress)? onProgress,
  }) async {
    final mirror = _normalizeUrl(settings.mirrorUrl);
    final baseUri = Uri.parse(mirror);
    final targetUrl = '$mirror/readfic/$id';

    onProgress?.call(
      Progress(
        stage: Stages.downloading,
        message: 'Получение оглавления...',
      ),
    );

    final mainRes = await _dio.get<String>(
      targetUrl,
      options: Options(
        responseType: ResponseType.plain,
        headers: {
          'user-agent': userAgentFB,
        },
      ),
    );

    final mainHtml = mainRes.data ?? '';
    final metadata = metadataParserFB(mainHtml, id, baseUri);
    final toc = parseTableOfContents(mainHtml, baseUri, metadata.title);

    final chapterTasks = List.generate(
      toc.length,
      (i) => ChapterDownloadTask(
        index: i + 1,
        title: toc[i].title,
        status: ChapterDownloadStatus.pending,
      ),
    );

    var completedCount = 0;
    final totalCount = toc.length;

    void emitProgress() {
      onProgress?.call(
        Progress(
          stage: Stages.downloading,
          current: completedCount,
          total: totalCount,
          chapterTasks: List.unmodifiable(chapterTasks),
          message: 'Загрузка глав: $completedCount из $totalCount',
        ),
      );
    }

    emitProgress();

    final results = List<BookSection?>.filled(toc.length, null);
    var nextIndex = 0;
    final maxConcurrent = settings.maxConcurrentDownloads.clamp(1, 20);

    Future<void> worker() async {
      while (true) {
        if (nextIndex >= toc.length) break;
        final cur = nextIndex++;
        final chapter = toc[cur];

        chapterTasks[cur] = chapterTasks[cur].copyWith(
          status: ChapterDownloadStatus.downloading,
        );
        emitProgress();

        try {
          final chapterRes = await _dio.get<String>(
            chapter.url.toString(),
            options: Options(
              responseType: ResponseType.plain,
              headers: {
                'user-agent': userAgentFB,
              },
            ),
          );

          final section = parseChapterSection(
            chapterRes.data ?? '',
            chapter.title,
          );
          results[cur] = section;
          chapterTasks[cur] = chapterTasks[cur].copyWith(
            status: ChapterDownloadStatus.completed,
          );
        } catch (e, trace) {
          logger.w(
            'Failed to download chapter ${chapter.title}',
            error: e,
            stackTrace: trace,
          );
          chapterTasks[cur] = chapterTasks[cur].copyWith(
            status: ChapterDownloadStatus.failed,
          );
        } finally {
          completedCount++;
          emitProgress();
        }
      }
    }

    final workerCount = maxConcurrent.clamp(1, toc.length);
    await Future.wait(List.generate(workerCount, (_) => worker()));

    final sections = results.whereType<BookSection>().toList();
    return BookContent(blocks: sections);
  }

  @override
  BookResourceResolver getResourceResolver(FBSettings settings) {
    final dio = Dio();
    return (request, {onByteProgress}) async {
      final rawUri = request.source ?? request.id;
      final mirror = _normalizeUrl(settings.mirrorUrl);
      final url = rawUri.startsWith('/') ? '$mirror$rawUri' : rawUri;

      try {
        final res = await dio.get<Uint8List>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {
              'user-agent': userAgentFB,
            },
          ),
          onReceiveProgress: (received, total) {
            onByteProgress?.call(received, total > 0 ? total : null);
          },
        );

        final bytes = res.data;
        if (bytes == null) return null;

        final headerContentType = res.headers.value('content-type');
        final mediaType = (headerContentType != null &&
                headerContentType.startsWith('image/'))
            ? headerContentType.split(';').first.trim()
            : _guessMediaType(url);

        return BookResource(
          id: request.id,
          mediaType: mediaType,
          bytes: bytes,
          originalUri: Uri.tryParse(url),
        );
      } catch (e, trace) {
        logger.w(
          'Failed to resolve Ficbook resource: $url',
          error: e,
          stackTrace: trace,
        );
        return null;
      }
    };
  }

  static String _normalizeUrl(String url) {
    var u = url.trim();
    if (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    if (!u.startsWith('http://') && !u.startsWith('https://')) {
      u = 'https://$u';
    }
    return u;
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
