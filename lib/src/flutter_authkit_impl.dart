import 'package:dio/dio.dart';
import 'package:flutter_authkit/src/core/enums/request_type.dart';
import 'package:flutter_authkit/src/core/handler/auth_error_handler.dart';
import 'package:flutter_authkit/src/core/services/dio.dart';
import 'package:flutter_authkit/src/core/services/token_service.dart';

class FlutterAuthKit {
  static final FlutterAuthKit _instance = FlutterAuthKit._internal();
  factory FlutterAuthKit() => _instance;

  final DioClient _dioClient = DioClient();
  final TokenService _tokenService = TokenService();

  FlutterAuthKit._internal();

  Future<T> _request<T>({
    required String endpoint,
    required RequestType method,
    Map<String, dynamic>? params,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      Response response;
      if (method == RequestType.POST) {
        response = await _dioClient.dio.post('/$endpoint', data: params);
      } else if (method == RequestType.GET) {
        response =
            await _dioClient.dio.get('/$endpoint', queryParameters: params);
      } else {
        throw Exception("Unsupported HTTP method: $method");
      }
      return fromJson(response.data);
    } on DioException catch (e) {
      throw AuthErrorHandler.fromDioError(e);
    }
  }

  // For Login
  Future<T> login<T>({
    required String loginEndpoint,
    Map<String, dynamic>? params,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return _request(
      endpoint: loginEndpoint,
      method: RequestType.POST,
      params: params,
      fromJson: fromJson,
    );
  }

  // For Register
  Future<T> register<T>({
    required String registerEndpoint,
    Map<String, dynamic>? params,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return _request(
      endpoint: registerEndpoint,
      method: RequestType.POST,
      params: params,
      fromJson: fromJson,
    );
  }

  // For Logout
  Future<void> logout({required String logoutEndpoint}) async {
    try {
      await _dioClient.dio.post('/$logoutEndpoint');
      await _tokenService.deleteToken();
    } on DioException catch (e) {
      throw AuthErrorHandler.fromDioError(e);
    }
  }

// Get Valid Token
  Future<String> getValidToken() async {
    final token = await _tokenService.getToken();
    if (token != null && !await _tokenService.isTokenExpired()) {
      return token;
    } else {
      return await refreshAccessToken();
    }
  }

  // Refresh Access Token
  Future<String> refreshAccessToken() async {
    final refreshToken = await _tokenService.getRefreshToken();
    final res = await _dioClient.dio
        .post('/refresh-token', data: {"refreshToken": refreshToken});
    final newAccessToken = res.data['accessToken'];
    await _tokenService.saveToken(token: newAccessToken);
    return newAccessToken;
  }
}
