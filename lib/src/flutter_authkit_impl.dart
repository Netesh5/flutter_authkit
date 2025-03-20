import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_authkit/flutter_authkit.dart';
import 'package:flutter_authkit/src/core/handler/cancle_handler.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

@LazySingleton()
class FlutterAuthKit {
  final TokenService tokenService;

  late DioClient dioClient;
  FlutterAuthKit({required this.tokenService});

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

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

  loginWithGoogle<T>(
      {required String googleEndpoint,
      Map<String, dynamic>? params,
      required T Function(Map<String, dynamic>) fromJson}) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const CancleHandler();
      final googleAuth = await googleUser.authentication;
      final token = googleAuth.accessToken;

      if (token == null) throw "Failed to fetch token";

      log(token, name: "Google Token");

      final res = await _request(
        endpoint: googleEndpoint,
        method: RequestType.POST,
        params: params,
        fromJson: fromJson,
      );
      return res;
    } on DioException catch (e) {
      throw AuthErrorHandler.fromDioError(e);
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  loginWithApple<T>() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      if (credential.identityToken == null) throw "Failed to fetch token";
      final token = credential.identityToken;
      log(token!, name: "Apple Token");
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const CancleHandler();
      }
      rethrow;
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }
}
