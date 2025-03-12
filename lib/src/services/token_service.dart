import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final String key;
  TokenService({this.key = "@Token"});
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken({required String token}) async {
    await _storage.write(key: key, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: key);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: key);
  }
}
