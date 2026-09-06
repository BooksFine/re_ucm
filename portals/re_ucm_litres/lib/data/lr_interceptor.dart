import 'package:dio/dio.dart';
import '../domain/constants.dart';

class LRInterceptor extends Interceptor {
  final String? sid;

  const LRInterceptor({this.sid});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({
      if (!options.headers.containsKey('Session-Id'))
        'Session-Id': sid ?? defaultSidLR,
      if (!options.headers.containsKey('app-id')) 'app-id': '1',
      'User-Agent': userAgentLR,
    });
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.data is Map) {
      final data = err.response!.data as Map;
      if (data['error'] is Map && data['error']['detail'] != null) {
        err = err.copyWith(message: data['error']['detail'].toString());
      } else if (data['errors'] != null) {
        err = err.copyWith(message: data['errors'].toString());
      }
    }
    handler.next(err);
  }
}
