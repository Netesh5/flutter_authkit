import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_authkit/src/core/services/token_service.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@LazySingleton()
class DioClient {
  final TokenService _tokenService = TokenService();
  bool _isRefreshing = false;

  final Dio dio;

  DioClient({required this.dio});

  void init({
    required String baseUrl,
    int connectionTimeoutMs = 5000,
    int receiveTimeoutMs = 5000,
    Map<String, dynamic>? headers,
  }) {
    dio.options = (BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: connectionTimeoutMs),
      receiveTimeout: Duration(milliseconds: receiveTimeoutMs),
      headers: headers ?? {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(_interceptor());
    if (kDebugMode) {
      dio.interceptors
          .add(PrettyDioLogger(requestBody: true, responseBody: true));
    }
  }

  InterceptorsWrapper _interceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenService.getToken();
        if (token != null) {
          options.headers = {
            ...(options.headers),
            "Authorization": "Bearer $token",
            'Content-Type': 'application/json',
          };
        } else {
          options.headers = {
            ...(options.headers),
            'Content-Type': 'application/json',
          };
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          return _handleTokenRefresh(e, handler);
        }
        return handler.next(e);
      },
    );
  }

  Future<void> _handleTokenRefresh(
      DioException e, ErrorInterceptorHandler handler) async {
    if (_isRefreshing) {
      return handler.next(e);
    }
    _isRefreshing = true;
    try {
      final newToken = await _tokenService.getToken();
      if (newToken != null) {
        dio.options.headers["Authorization"] = "Bearer $newToken";
        final retryResponse = await dio.fetch(e.requestOptions);
        return handler.resolve(retryResponse);
      }
    } catch (error) {
      await _tokenService.deleteToken();
    } finally {
      _isRefreshing = false;
    }

    return handler.next(e);
  }
}
