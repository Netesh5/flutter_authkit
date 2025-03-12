import 'package:dio/dio.dart';
import 'package:flutter_authkit/src/handler/auth_error_handler.dart';
import 'package:flutter_authkit/src/services/dio.dart';
import 'package:flutter_authkit/src/services/token_service.dart';

class FlutterAuthKit {
  static final FlutterAuthKit _instance = FlutterAuthKit._internal();
  factory FlutterAuthKit() => _instance;

  final DioClient _dioClient = DioClient();
  final TokenService _tokenService = TokenService();

  FlutterAuthKit._internal();

  Future<T> _request<T>({
    required String endpoint,
    required String method,
    Map<String, dynamic>? params,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      Response response;
      if (method.toUpperCase() == 'POST') {
        response = await _dioClient.dio.post('/$endpoint', data: params);
      } else if (method.toUpperCase() == 'GET') {
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
      method: 'POST',
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
      method: 'POST',
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
}
