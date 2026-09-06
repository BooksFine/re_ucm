import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'lr_interceptor.dart';
import 'models/lr_art.cg.dart';

part '../.gen/data/litres_api.cg.g.dart';

@RestApi(baseUrl: 'https://api.litres.ru')
abstract class LitresAPI {
  factory LitresAPI(Dio dio, {String baseUrl}) = _LitresAPI;

  static LitresAPI create({String? sid}) {
    final dio = Dio()..interceptors.add(LRInterceptor(sid: sid));
    return LitresAPI(dio);
  }

  @GET('/foundation/api/arts/{id}')
  Future<LRArtResponse> getArt(@Path('id') String id);

  @GET('/foundation/api/arts/{id}/files/grouped')
  Future<LRFilesGroupedResponse> getFilesGrouped(@Path('id') String id);

  @GET('/foundation/api/users/me/detailed')
  Future<LRMeResponse> getMe();

  @POST('/foundation/api/auth/login')
  Future<LRAuthResponse> login(@Body() Map<String, dynamic> body);
}
