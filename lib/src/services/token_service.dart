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
  }

  DateTime getTokenExpiryDate(String token) {
    try {
      return JwtDecoder.getExpirationDate(token);
    } on Exception catch (e) {
      throw Exception("Error getting token expiry date: $e");
    }
  }
}
