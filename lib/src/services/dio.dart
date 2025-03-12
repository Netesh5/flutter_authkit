import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_authkit/src/services/token_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient {
  final Dio _dio = Dio();

  Dio get dio => _dio;

  final TokenService _tokenService = TokenService();

  void init(
      {required String baseUrl,
      int connectionTimeoutMs = 5000,
      int receiveTimeoutMs = 3000,
      Map<String, dynamic>? headers}) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: connectionTimeoutMs);
    _dio.options.receiveTimeout = Duration(milliseconds: receiveTimeoutMs);
    _dio.options.headers = headers ?? {"Accept": "Application/json"};

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenService.getToken();
        if (token != null) {
          options.headers = {
            ...(options.headers),
            "Authorization": "Bearer $token",
            "Accept": "Application/json",
          };
        } else {
          options.headers = {
            ...(options.headers),
            "Accept": "Application/json",
          };
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));

    if (kDebugMode) _dio.interceptors.add(PrettyDioLogger());
  }
}
