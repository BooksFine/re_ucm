import 'package:dart_mappable/dart_mappable.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../portals/domain/portal_factory.dart';

part '../../../.gen/features/recent_books/domain/recent_book.cg.mapper.dart';

@MappableClass(includeCustomMappers: [PortalMapper()])
class RecentBook with RecentBookMappable {
  final String id;
  final String title;
  final String authors;
  final String? coverUrl;
  final String? seriesName;
  final int? seriesNumber;
  final Portal portal;
  final DateTime added;

  RecentBook({
    required this.id,
    required this.title,
    required this.authors,
    this.coverUrl,
    this.seriesName,
    this.seriesNumber,
    required this.portal,
    required this.added,
  });

  static const fromJson = RecentBookMapper.fromJson;
}

class PortalMapper extends SimpleMapper<Portal> {
  const PortalMapper();

  @override
  Portal decode(dynamic value) {
    if (value is Map<String, dynamic>) {
      return PortalFactory.fromJson(value);
    }
    return PortalFactory.fromCode(value.toString());
  }

  @override
  dynamic encode(Portal value) {
    return PortalFactory.toJson(value);
  }
}
