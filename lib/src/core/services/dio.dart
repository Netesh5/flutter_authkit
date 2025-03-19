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

  DioClient(@Named('baseUrl') String baseUrl,
      @Named('headers') Map<String, dynamic> headers, this.tokenService)
      : dio = Dio() {
    init(baseUrl: baseUrl, headers: headers);
  }

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
          return _handleTokenRefresh(e, handler);
        }
        return handler.next(e);
      },
    );
  }

  // Future<void> _handleTokenRefresh(
  //     DioException e, ErrorInterceptorHandler handler) async {
  //   if (_isRefreshing) {
  //     return handler.next(e);
  //   }
  //   _isRefreshing = true;
  //   try {
  //     final newToken = await tokenService.getRefreshToken();
  //     if (newToken != null) {
  //       dio.options.headers["Authorization"] = "Bearer $newToken";
  //       final retryResponse = await dio.fetch(e.requestOptions);
  //       return handler.resolve(retryResponse);
  //     }
  //   } catch (error) {
  //     await tokenService.deleteToken();
  //   } finally {
  //     _isRefreshing = false;
  //   }

  //   return handler.next(e);
  // }

  Future<void> _handleTokenRefresh(
      DioException e, ErrorInterceptorHandler handler) async {
    final refreshTokenCompleter = Completer<void>();
    if (_isRefreshing) {
      await refreshTokenCompleter.future;
      if ((await tokenService.getToken()) != null) {
        final retryResponse = await dio.fetch(e.requestOptions);
        return handler.resolve(retryResponse);
      } else {
        return handler.reject(e);
      }
    }

    _isRefreshing = true;

    try {
      final newToken = await tokenService.getRefreshToken();
      if (newToken != null) {
        await tokenService.saveToken(token: newToken);
        dio.options.headers["Authorization"] = "Bearer $newToken";

        final retryResponse = await dio.fetch(e.requestOptions);
        return handler.resolve(retryResponse);
      } else {
        await tokenService.deleteToken();
      }
    } catch (error) {
      await tokenService.deleteToken();
      return handler.reject(e);
    } finally {
      _isRefreshing = false;
      refreshTokenCompleter.complete();
    }

    return handler.next(e);
  }
}
