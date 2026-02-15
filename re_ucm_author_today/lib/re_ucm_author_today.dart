import 'package:re_ucm_author_today/author_today_service.dart';
import 'package:re_ucm_author_today/data/models/at_settings.cg.dart';
import 'package:re_ucm_author_today/domain/constants.dart';
import 'package:re_ucm_core/models/portal.dart';

class AuthorToday implements Portal<ATSettings> {
  late final PortalService<ATSettings> _service = AuthorTodayService(this);

  @override
  String get code => codeAT;

  @override
  String get name => nameAT;

  @override
  String get url => urlAT;

  @override
  PortalLogo get logo => PortalLogo(
    assetPath: 'assets/logo.svg',
    packageName: 're_ucm_author_today',
  );

  @override
  PortalService<ATSettings> get service => _service;
}
