import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'at_interceptor.dart';
import 'models/at_chapter.cg.dart';
import 'models/at_work_metadata.cg.dart';

part '../.gen/data/author_today_api.cg.g.dart';

@RestApi(baseUrl: 'https://api.author.today/v1')
abstract class AuthorTodayAPI {
  factory AuthorTodayAPI(Dio dio, {String baseUrl}) = _AuthorTodayAPI;

  //TODO
  static AuthorTodayAPI create({String? token}) {
    final dio = Dio()
      ..interceptors.add(
        ATInterceptor(
          token: token,
          onRelogin: () {
            throw Exception('Token expired');
          },
        ),
      );
    return AuthorTodayAPI(dio);
  }

  @GET('https://author.today/account/bearer-token')
  Future<HttpResponse> login(@Header('cookie') String cookies);

  @GET('/account/current-user')
  Future<HttpResponse> checkUser(@Header('Authorization') String token);

  @POST('/account/refresh-token')
  Future<HttpResponse> refreshToken();

  @GET('/work/{id}/details')
  Future<HttpResponse<ATWorkMetadata>> getMeta(@Path('id') String id);

  @GET('/work/{id}/chapter/many-texts')
  Future<HttpResponse<List<ATChapter>>> getManyTexts(@Path('id') String id);
}
