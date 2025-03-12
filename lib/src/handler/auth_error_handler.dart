import 'package:dio/dio.dart';

class AuthErrorHandler implements Exception {
  late final String message;

  AuthErrorHandler.fromDioError(DioException dioError) {
    message = _mapDioErrorToMessage(dioError);
  }

  String _mapDioErrorToMessage(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        return "Request to server was cancelled";
      case DioExceptionType.connectionTimeout:
        return "Connection timeout with server";
      case DioExceptionType.unknown:
        return "Connection to server failed due to internet connection";
      case DioExceptionType.receiveTimeout:
        return "Receive timeout in connection with server";
      case DioExceptionType.badResponse:
        return _handleError(dioError.response?.statusCode);
      case DioExceptionType.sendTimeout:
        return "Send timeout in connection with server";
      default:
        return "Something went wrong";
    }
  }

  String _handleError(int? statusCode) {
    if (statusCode == null) return 'Unknown error occurred';
    switch (statusCode) {
      case 400:
        return 'Bad request, please check your request';
      case 404:
        return 'The requested resource was not found';
      case 500:
        return 'Internal server error';
      default:
        return 'Oops something went wrong, try again later';
    }
  }

  @override
  String toString() => message;
}
