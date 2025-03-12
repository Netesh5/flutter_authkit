import 'package:flutter_authkit/src/handler/auth_error_handler.dart';
import 'package:flutter_authkit/src/services/dio.dart';

class FlutterAuthKit {
  final DioClient _dioClient = DioClient();
  Future login({Map<String, dynamic>? params}) async {
    try {
      final res = await _dioClient.dio.post('/login', data: params);
      return res.data;
    } on AuthErrorHandler catch (e) {
      throw e.message;
    }
  }
}
