import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_authkit/src/core/services/token_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  final Dio _dio = Dio();
  final TokenService _tokenService = TokenService();
  bool _isRefreshing = false;

  DioClient._internal() {
    _dio.interceptors.add(_interceptor());
    if (kDebugMode) {
      _dio.interceptors
          .add(PrettyDioLogger(requestBody: true, requestHeader: true));
    }
  }

  Dio get dio => _dio;

  void init({
    required String baseUrl,
    int connectionTimeoutMs = 5000,
    int receiveTimeoutMs = 3000,
    Map<String, dynamic>? headers,
  }) {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: connectionTimeoutMs),
      receiveTimeout: Duration(milliseconds: receiveTimeoutMs),
      headers: headers ?? {"Accept": "Application/json"},
    );
  }

  InterceptorsWrapper _interceptor() {
    return InterceptorsWrapper(
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
        _dio.options.headers["Authorization"] = "Bearer $newToken";
        final retryResponse = await _dio.fetch(e.requestOptions);
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
