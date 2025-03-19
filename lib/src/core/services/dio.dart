import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_authkit/src/core/services/token_service.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@LazySingleton()
class DioClient {
  final TokenService tokenService;
  bool _isRefreshing = false;

  final Dio dio;

  DioClient(
      @Named('baseUrl') String baseUrl,
      @Named('headers') Map<String, dynamic> headers,
      this.tokenService,
      @Named('refreshEndpoint') String refreshEndpoint)
      : dio = Dio() {
    init(baseUrl: baseUrl, headers: headers, refreshEndpoint: refreshEndpoint);
  }

  void init({
    required String baseUrl,
    int connectionTimeoutMs = 5000,
    int receiveTimeoutMs = 5000,
    Map<String, dynamic>? headers,
    String? refreshEndpoint,
  }) {
    dio.options = (BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: connectionTimeoutMs),
      receiveTimeout: Duration(milliseconds: receiveTimeoutMs),
      headers: headers ?? {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(_interceptor(refreshEndpoint: refreshEndpoint));
    if (kDebugMode) {
      dio.interceptors
          .add(PrettyDioLogger(requestBody: true, responseBody: true));
    }
  }

  InterceptorsWrapper _interceptor({String? refreshEndpoint}) {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenService.getToken();
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
          return _handleTokenRefresh(e, handler,
              refreshEndpoint: refreshEndpoint);
        }
        return handler.next(e);
      },
    );
  }

  Future<void> _handleTokenRefresh(
      DioException e, ErrorInterceptorHandler handler,
      {String? refreshEndpoint}) async {
    if (_isRefreshing) {
      return handler.next(e); // If already refreshing, just proceed
    }

    _isRefreshing = true;

    try {
      final newAccessToken = await refreshAccessToken();
      if (newAccessToken != null) {
        dio.options.headers["Authorization"] = "Bearer $newAccessToken";
        final retryResponse = await dio.fetch(e.requestOptions);
        return handler.resolve(retryResponse);
      }
    } catch (error) {
      await tokenService.deleteToken(); // Clear tokens if refresh fails
    } finally {
      _isRefreshing = false;
    }

    return handler.next(e);
  }

  Future<String?> refreshAccessToken({String? refreshEndpoint}) async {
    final refreshToken = await tokenService.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await dio.post(
        refreshEndpoint ?? '/refresh',
        data: {"refreshToken": refreshToken},
      );

      final newAccessToken = response.data['accessToken'];
      final newRefreshToken = response.data['refreshToken'];

      // Save the new tokens
      await tokenService.saveToken(token: newAccessToken);
      if (newRefreshToken != null) {
        await tokenService.saveRefreshToken(refreshToken: newRefreshToken);
      }

      return newAccessToken;
    } catch (e) {
      await tokenService.deleteToken(); // Logout if refresh fails
      return null;
    }
  }
}
