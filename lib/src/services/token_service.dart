import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenService {
  final String key;
  final String expiryKey;
  TokenService({this.key = "@Token", this.expiryKey = "@TokenExpiry"});

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken({
    required String token,
  }) async {
    await _storage.write(key: key, value: token);
    await _storage.write(
        key: expiryKey, value: getTokenExpiryDate(token).toIso8601String());
  }

  Future<String?> getToken() async {
    return await _storage.read(key: key);
  }

  Future<DateTime?> getTokenExpiry() async {
    String? expiryString = await _storage.read(key: expiryKey);
    if (expiryString != null) {
      return DateTime.parse(expiryString);
    }
    return null;
  }

  Future<bool> isTokenExpired() async {
    final expiryDate = await getTokenExpiry();
    if (expiryDate == null) return true;
    return DateTime.now().isAfter(expiryDate);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: key);
    await _storage.delete(key: expiryKey);
  }

  DateTime getTokenExpiryDate(String token) {
    return JwtDecoder.getExpirationDate(token);
  }
}
