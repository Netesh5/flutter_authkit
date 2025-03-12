import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenService {
  final String key;
  TokenService({this.key = "@Token"});

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken({
    required String token,
  }) async {
    try {
      await _storage.write(key: key, value: token);
      DateTime expiryDate = JwtDecoder.getExpirationDate(token);
      await _storage.write(
          key: "$key-expiry", value: expiryDate.toIso8601String());
    } on Exception catch (e) {
      throw Exception("Error saving token: $e");
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: key);
    } on Exception catch (e) {
      throw Exception("Error reading token: $e");
    }
  }

  Future<bool> isTokenExpired() async {
    final token = await getToken();
    final expiryString = await _storage.read(key: "$key-expiry");
    if (token == null || expiryString == null) return true;
    final expiryDate = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiryDate);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: key);
    await _storage.delete(key: "$key-expiry");
  }

  Future<void> saveRefreshToken({
    required String refreshToken,
  }) async {
    try {
      await _storage.write(key: "$key-refresh", value: refreshToken);
    } on Exception catch (e) {
      throw Exception("Error saving refresh token: $e");
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: "$key-refresh");
    } on Exception catch (e) {
      throw Exception("Error reading refresh token: $e");
    }
  }
}
