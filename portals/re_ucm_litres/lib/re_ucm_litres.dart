import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_litres/data/models/lr_settings.cg.dart';
import 'package:re_ucm_litres/domain/constants.dart';
import 'package:re_ucm_litres/litres_service.dart';

class Litres implements Portal<LRSettings> {
  late final PortalService<LRSettings> _service = LitresService();

  @override
  String get code => codeLitres;

  @override
  String get name => nameLitres;

  @override
  String get url => urlLitres;

  @override
  PortalLogo get logo => const PortalLogo(
    assetPath: 'assets/logo.svg',
    packageName: 're_ucm_litres',
  );

  @override
  PortalService<LRSettings> get service => _service;
}
