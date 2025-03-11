import 'package:dio/dio.dart';

class DioClient {
  static final Dio _dio = Dio();

  static Dio get dio => _dio;

  static void init(
      {required String baseUrl,
      required String token,
      int connectionTimeoutMs = 5000,
      int receiveTimeoutMs = 3000,
      Map<String, dynamic>? headers}) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: connectionTimeoutMs);
    _dio.options.receiveTimeout = Duration(milliseconds: receiveTimeoutMs);
    _dio.options.headers = headers ??
        {
          'Content-Type': 'application/json',
        };

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }
}
