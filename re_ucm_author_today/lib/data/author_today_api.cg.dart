import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../application/at_internal_service.dart';
import 'at_interceptor.dart';
import 'models/at_chapter.cg.dart';
import 'models/at_work_metadata.cg.dart';

part '../.gen/data/author_today_api.cg.g.dart';

@RestApi(baseUrl: 'https://api.author.today/v1')
abstract class AuthorTodayAPI {
  factory AuthorTodayAPI(Dio dio, {String baseUrl}) = _AuthorTodayAPI;

  static AuthorTodayAPI create({required ATInternalService service}) {
    final dio = Dio()..interceptors.add(ATInterceptor(service));
    return AuthorTodayAPI(dio);
  }

  @GET('https://author.today/account/bearer-token')
  Future<HttpResponse> login(@Header('cookie') String cookies);

  @GET('/account/current-user')
  Future<HttpResponse> checkUser(@Header('Authorization') token);

  @POST('/account/refresh-token')
  Future<HttpResponse> refreshToken();

  @GET('/work/{id}/details')
  Future<HttpResponse<ATWorkMetadata>> getMeta(@Path('id') String id);

  @GET('/work/{id}/chapter/many-texts')
  Future<HttpResponse<List<ATChapter>>> getManyTexts(@Path('id') String id);
}
