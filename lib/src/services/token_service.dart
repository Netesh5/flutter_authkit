import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken({required String key, required String token}) async {
    await _storage.write(key: '', value: token);
  }

  Future<String?> getToken({required String key}) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteToken({required String key}) async {
    await _storage.delete(key: key);
  }
}
