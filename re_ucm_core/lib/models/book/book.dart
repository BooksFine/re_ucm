part of '../book.dart';

class Book {
  final String id;
  final String url;
  final String title;
  final List<Author> authors;
  final String? annotation;
  final bool isFinished;
  final DateTime lastUpdateTime;
  final String? coverUrl;
  final List<Genre> genres;
  final Series? series;
  final List<String>? tags;
  final int? textLength;
  final List<Chapter> chapters = [];
  final Portal portal;

  Book({
    required this.id,
    required this.url,
    required this.title,
    required this.authors,
    this.annotation,
    required this.isFinished,
    required this.lastUpdateTime,
    this.coverUrl,
    required this.genres,
    this.series,
    this.tags,
    this.textLength,
    required this.portal,
  });
}
