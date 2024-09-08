import 'package:flutter_svg/flutter_svg.dart';

enum Portal {
  authorToday(
    'https://author.today',
    'AuthorToday',
    'AT',
    SvgAssetLoader('lib/assets/portals/author.today_logo.svg'),
  );
  // litnet(
  //   'https://litnet.com',
  //   'Litnet',
  //   'LN',
  //   SvgAssetLoader('lib/assets/portals/litnet.com_logo.svg'),
  // );

  final String url;
  final String name;
  final String code;
  final SvgAssetLoader logo;

  const Portal(this.url, this.name, this.code, this.logo);

  static Portal fromCode(String code) {
    try {
      return _portalsCodeMap[code]!;
    } catch (e) {
      throw ArgumentError('Invalid portal code');
    }
  }

  static Portal fromUrl(Uri uri) {
    try {
      return _portalsUrlMap[uri.origin]!;
    } catch (e) {
      throw ArgumentError('Invalid portal url');
    }
  }
}

final _portalsUrlMap = {
  for (var portal in Portal.values) portal.url: portal,
};

final _portalsCodeMap = {
  for (var portal in Portal.values) portal.code: portal,
};
