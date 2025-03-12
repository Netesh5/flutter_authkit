import 'package:flutter_authkit/src/handler/auth_error_handler.dart';
import 'package:flutter_authkit/src/services/dio.dart';

class FlutterAuthKit {
  final DioClient _dioClient = DioClient();

  // For Login Purpose
  Future<T> login<T>(
      {required String loginEndPont,
      Map<String, dynamic>? params,
      required T Function(Map<String, dynamic>) fromJson}) async {
    try {
      final res = await _dioClient.dio.post('/$loginEndPont', data: params);
      return fromJson(res.data);
    } on AuthErrorHandler catch (e) {
      throw e.message;
    }
  }

  // For Register Purpose
  Future<T> register<T>(
      {required String registerEndpoint,
      Map<String, dynamic>? params,
      required T Function(Map<String, dynamic>) fromJson}) async {
    try {
      final res = await _dioClient.dio.post('/$registerEndpoint', data: params);
      return fromJson(res.data);
    } on AuthErrorHandler catch (e) {
      throw e.message;
    }
  }

  // For Logout Purpose
  Future<T> logout<T>(
      {required String logoutEndpoint,
      T Function(Map<String, dynamic>)? fromJson}) async {
    try {
      final res = await _dioClient.dio.post('/$logoutEndpoint');
      if (fromJson != null) {
        return fromJson(res.data);
      }
      return res.data;
    } on AuthErrorHandler catch (e) {
      throw e.message;
    }
  }
}
