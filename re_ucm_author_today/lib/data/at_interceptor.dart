import 'dart:async';
import 'package:dio/dio.dart';
import '../application/at_internal_service.dart';
import '../domain/constants.dart';

class ATInterceptor extends Interceptor {
  final ATInternalService service;

  ATInterceptor(this.service);

  @override
  onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path != '/account/bearer-token') {
      options.headers.addAll({
        if (!options.headers.containsKey('Authorization'))
          "Authorization": "Bearer ${service.token ?? 'guest'}",
        "user-agent": userAgentAT,
      });
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.data is Map) {
      if (err.response?.data['code'] == 'ExpiredToken') {
        await service.relogin();
        final String? newToken = service.token;

        if (newToken != null) {
          final RequestOptions options = err.requestOptions;
          options.headers["Authorization"] = 'Bearer $newToken';
          final Response response = await Dio().fetch(options);
          return handler.resolve(response);
        }
      }

      final Map error = err.response!.data as Map;
      err = err.copyWith(message: error['message'] ?? error);
    }

    return handler.next(err);
  }
}

// BJxSxMRnsgn2QMjfD9geoQPeJ7cqI5EMCJsRzsJYvQ6qCDTMeMcg4w3yxHsFLKlByetb-GILtmQkCGj-pmTheJO2fcOWTzXPCsfz6P4QcIndtOxzLXZQZTHNcUFMbpoh_EAt7PWjvweJi_XcrvVxbg3Yel5d9dSBhd-c9NxcTmRYxBaVYmKwqXn2MLYqzy6fmVnc2s52Zi0bIS_H_k-hJwXV-R22Ll7jiaUXWehGcJlXdSERI4ABgISIVRfwDAUF5JgJ5vlUHlQnLKPLTM2ec9FCFDndYg_6SZBqc75FmI677iYchs2FLiog4EQu1977mArGHmuZxiimUkcy_Q1zWAqjy-70NpJy3mZo4fYQF-PLcRaE8v8TznBEcBMFXpU_ROuBfCocRDlzxx7wnBAv25JL254PRkrHaa8GfIOkI5sijMv90KKk4T2rNt6XRN2RqghA8GhiDLGg4XMtH4XabPAXQwr2PExgG0YqQukW7p6iamU60tsdudTpQ7sj6oGPWbYrq7qI1arzXeV_ECG6ni-_JZr3B19U_xed_EJxIF0gQWOfcoWnNbAWRX9OwQB0pfc9xwsPGFpqn7p-6KtNGop1nd42IqmotuT-Em7fjLl7GlDEhOaIhrGm7GOWx2w248Nmyw
