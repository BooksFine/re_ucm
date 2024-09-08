import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../../../core/constants.dart';
import '../../../core/logger.dart';
import '../../book/domain/book.dart';
import '../../book/domain/progress.dart';
import '../../portals/author.today/domain/constants.dart';
import '../../portals/portal.dart';
import 'html_to_fb2.dart.dart';

Future<Uint8List> convertToFB2(
  Book book,
  Function(Progress) progressCallback,
) async {
  // Создаем порт для получения сообщений
  ReceivePort receivePort = ReceivePort();

  // Создаем новый изолят
  Isolate.spawn(
    convertToFB2Isolate,
    {'sendPort': receivePort.sendPort, 'data': book},
  );

  // Устанавливаем обработчик для получения сообщений
  await for (var message in receivePort) {
    if (message is Progress) {
      progressCallback(message);
    } else if (message is Uint8List) {
      return message;
    }
  }

  throw Exception('Did not receive book data from isolate');
}

List<String> findImages(List<String> htmls) {
  var result = <String>[];
  for (var html in htmls) {
    var document = parse(html);
    var images = document.querySelectorAll('img');
    result.addAll(
      images
          .where((img) => img.attributes.containsKey('src'))
          .map((img) => img.attributes['src']!),
    );
  }
  return result;
}

Future<void> convertToFB2Isolate(Map<String, dynamic> args) async {
  SendPort sendPort = args['sendPort'];
  Book data = args['data'];
  progressCallback(progress) {
    sendPort.send(progress);
  }

  progressCallback(Progress(stage: Stages.analyzing));

  var chapters = <String, List<XmlElement>>{};
  for (var element in data.chapters) {
    chapters[element.title] = htmlToFB2(element.content);
  }

  var images = <String, String>{};
  var sources = findImages(data.chapters.map((e) => e.content).toList());
  if (data.coverUrl != null) {
    sources.add(data.coverUrl!);
  }

  var current = 0;
  progressCallback(
    Progress(
      stage: Stages.imageDownloading,
      total: sources.length,
      current: current,
    ),
  );

  final dio = Dio();
  await Future.wait(
    sources.map(
      (src) async {
        try {
          final url = src[0] == '/' ? data.portal.url + src : src;
          Response<Uint8List> res = await dio.get<Uint8List>(
            url,
            options: Options(
              responseType: ResponseType.bytes,
              headers: {
                //Костыль для адекватной загрузки картинок с АТ из-за рубежа
                if (data.portal == Portal.authorToday)
                  "user-agent": userAgentAT,
              },
            ),
          );
          images[getTagFromSource(src)] = base64Encode(res.data!);
          progressCallback(
            Progress(
              stage: Stages.imageDownloading,
              total: sources.length,
              current: ++current,
            ),
          );
        } catch (e) {
          logger.e('Error downloading image $src', error: e);
        }
      },
    ),
  );

  progressCallback(Progress(stage: Stages.building));

  final book = XmlBuilder();
  book.processing('xml', 'version="1.0" encoding="utf-8"');
  book.element('FictionBook', attributes: {
    'xmlns': 'http://www.gribuser.ru/xml/fictionbook/2.0',
    'xmlns:l': 'http://www.w3.org/1999/xlink'
  }, nest: () {
    book.element(
      'description',
      nest: () {
        book.element('title-info', nest: () {
          for (var genre in data.genres) {
            book.element('genre', nest: genre.en);
          }

          for (var author in data.authors) {
            var fullName = author.name.split(' ');
            book.element('author', nest: () {
              switch (fullName.length) {
                case 1:
                  book.element('nickname', nest: fullName[0]);
                  break;
                case 2:
                  book.element('first-name', nest: fullName[0]);
                  book.element('last-name', nest: fullName[1]);
                  break;
                case 3:
                  book.element('first-name', nest: fullName[1]);
                  book.element('middle-name', nest: fullName[2]);
                  book.element('last-name', nest: fullName[0]);
                  break;
                default:
                  break;
              }
              book.element('home-page', nest: author.url);
            });
          }
          book.element('book-title', nest: data.title);

          if (data.annotation != null) {
            book.element('annotation', nest: () {
              for (var element in htmlToFB2(data.annotation!)) {
                book.element(element.name.toString(), nest: element.nodes);
              }
            });
          }
          if (data.tags != null) {
            book.element('keywords', nest: data.tags!.join(', '));
          }

          final dateFormat = DateFormat('yyyy-MM-dd');
          final formattedDate = dateFormat.format(data.lastUpdateTime);
          book.element(
            'date',
            attributes: {'value': formattedDate},
            nest: DateFormat('d MMMM yyyy г.').format(data.lastUpdateTime),
          );

          book.element('lang', nest: 'ru');

          if (data.series != null) {
            book.element('sequence', attributes: {
              'name': data.series!.name,
              'number': data.series!.number.toString(),
            });
          }
          if (data.coverUrl != null) {
            book.element('coverpage', nest: () {
              book.element('image', attributes: {
                'l:href': '#${getTagFromSource(data.coverUrl!)}'
              });
            });
          }
        });
        book.element('document-info', nest: () {
          book.element('author', nest: () {
            book.element('nickname', nest: 'Adherent-GA');
          });
          book.element(
            'program-used',
            nest: ' ReUltimateCopyManager $appVersion',
          );

          final dateFormat = DateFormat('yyyy-MM-dd');
          final formattedDate = dateFormat.format(data.lastUpdateTime);
          book.element(
            'date',
            attributes: {'value': formattedDate},
            nest: DateFormat('d MMMM yyyy г.').format(data.lastUpdateTime),
          );
          book.element('src-url', nest: data.url);
          book.element('id', nest: 'UCM-${data.portal.code}-${data.id}');
          book.element('version', nest: '1.0');
          book.element(
            'history',
            nest: () {
              book.element('p',
                  nest: '1.0 – Создание файла [ReUCM $appVersion]');
            },
          );
        });
      },
    );
    book.element('body', nest: () {
      book.element(
        'title',
        nest: () {
          book.element('p', nest: data.title);
        },
      );
      for (var element in chapters.entries) {
        book.element('section', nest: () {
          book.element('title', nest: () {
            book.element('p', nest: element.key);
          });
          for (var element in element.value) {
            book.element(element.name.toString(), nest: element.nodes);
          }
        });
      }
      book.element('section', nest: () {
        book.element('title', nest: () {
          book.element('p', nest: 'Послесловие @books_fine');
        });
        book.element('empty-line');
        book.element('p', nest: () {
          book.text('Эту книгу вы прочли бесплатно благодаря Telegram каналу ');
          book.element(
            'a',
            attributes: {'l:href': 'https://t.me/BookFine'},
            nest: '@books_fine',
          );
        });
        book.element('empty-line');
        book.element('p',
            nest: 'У нас вы найдете другие книги (или продолжение этой).');
        book.element('p', nest: () {
          book.text('Еще есть активный чат: ');
          book.element(
            'a',
            attributes: {'l:href': 'https://t.me/books_fine_com'},
            nest: '@books_fine_com',
          );
        });
        book.element('empty-line');
        book.element(
          'p',
          nest:
              'Если вам понравилось, поддержите автора наградой, или активностью.',
        );
        book.element('p', nest: () {
          book.element('strong', nest: 'Страница книги: ');
          book.element('a', attributes: {'l:href': data.url}, nest: data.title);
        });
        book.element('empty-line');
      });
    });

    images.forEach((key, value) {
      book.element('binary',
          attributes: {
            'id': key,
            'content-type': 'image/png',
          },
          nest: value);
    });
  });

  final bookXml = book.buildDocument();

  final bookXmlString = bookXml.toXmlString(
    pretty: true,
    preserveWhitespace: (value) =>
        value is XmlElement && value.name.local == 'p',
    indent: ' ',
  );
  final bookXmlBytes = utf8.encode(bookXmlString);

  progressCallback(Progress(stage: Stages.done));

  sendPort.send(bookXmlBytes);
}
