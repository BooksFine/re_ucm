import 'package:re_ucm_core/models/portal.dart';
import 'data/models/fb_settings.cg.dart';
import 'domain/constants.dart';
import 'ficbook_service.dart';

export 'data/models/fb_settings.cg.dart';
export 'domain/constants.dart';
export 'ficbook_service.dart';

class Ficbook implements Portal<FBSettings> {
  late final PortalService<FBSettings> _service = FicbookService();

  @override
  String get code => codeFB;

  @override
  String get name => nameFB;

  @override
  String get url => urlFB;

  @override
  PortalLogo get logo => const PortalLogo(
        assetPath: 'assets/logo.svg',
        packageName: 're_ucm_ficbook',
      );

  @override
  PortalService<FBSettings> get service => _service;
}
