import 'package:dio/dio.dart';
import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class FlutterAuthKit {
  final TokenService tokenService;

  late DioClient dioClient;
  FlutterAuthKit({required this.tokenService});

  init(
      {required String baseUrl,
      Map<String, dynamic>? headers,
      String? refreshEndpoint}) {
    if (g.isRegistered<DioClient>()) {
      g.unregister<DioClient>();
    }
    g.registerSingleton<DioClient>(
      DioClient(baseUrl, headers ?? {}, tokenService, refreshEndpoint ?? ""),
    );

    dioClient = g<DioClient>();
  }

  Future<T> _request<T>({
    required String endpoint,
    required RequestType method,
    Map<String, dynamic>? params,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      Response response;
      if (method == RequestType.POST) {
        response = await dioClient.dio.post('/$endpoint', data: params);
      } else if (method == RequestType.GET) {
        response =
            await dioClient.dio.get('/$endpoint', queryParameters: params);
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
    final res = await _request(
      endpoint: loginEndpoint,
      method: RequestType.POST,
      params: params,
      fromJson: fromJson,
    );

    if (res is AuthResponse) {
      await tokenService.saveToken(token: res.accessToken);
      if (res.refreshToken.isNotEmpty) {
        await tokenService.saveRefreshToken(refreshToken: res.refreshToken);
      }
    }
    return res;
  }

  // For Register
  Future<T> register<T>({
    required String registerEndpoint,
    Map<String, dynamic>? params,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return await _request(
      endpoint: registerEndpoint,
      method: RequestType.POST,
      params: params,
      fromJson: fromJson,
    );
  }

  // For Logout
  Future<void> logout({String? logoutEndpoint}) async {
    try {
      if (logoutEndpoint != null) {
        await dioClient.dio.post('/$logoutEndpoint');
      }
      await tokenService.deleteToken();
    } on DioException catch (e) {
      throw AuthErrorHandler.fromDioError(e);
    }
  }

// // Get Valid Token
//   Future<String> getValidToken() async {
//     final token = await tokenService.getToken();
//     if (token != null && !await tokenService.isTokenExpired()) {
//       return token;
//     } else {
//       return await refreshAccessToken();
//     }
//   }

//   // Refresh Access Token
//   Future<String> refreshAccessToken() async {
//     final refreshToken = await tokenService.getRefreshToken();
//     final res = await dioClient.dio
//         .post('/refresh-token', data: {"refreshToken": refreshToken});
//     final newAccessToken = res.data['accessToken'];
//     await tokenService.saveToken(token: newAccessToken);
//     return newAccessToken;
//   }

  Future<T> request<T>({
    required String endPoint,
    Map<String, dynamic>? params,
    required RequestType method,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final res = await _request(
      endpoint: endPoint,
      method: method,
      params: params,
      fromJson: fromJson,
    );
    return res;
  }
}
