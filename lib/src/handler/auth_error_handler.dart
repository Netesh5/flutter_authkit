import 'package:dio/dio.dart';

class AuthErrorHandler implements Exception {
  final String message;

  AuthErrorHandler.fromDioError(DioException dioError)
      : message = _mapDioErrorToMessage(dioError);

  static String _mapDioErrorToMessage(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        return "Request to server was cancelled";
      case DioExceptionType.connectionTimeout:
        return "Connection timeout with server";
      case DioExceptionType.receiveTimeout:
        return "Receive timeout in connection with server";
      case DioExceptionType.sendTimeout:
        return "Send timeout in connection with server";
      case DioExceptionType.connectionError:
        return "No internet connection";
      case DioExceptionType.unknown:
        return "Unexpected error occurred";
      case DioExceptionType.badResponse:
        return _handleError(dioError.response);
      default:
        return "Something went wrong";
    }
  }

  static String _handleError(Response<dynamic>? response) {
    if (response == null) return 'Unknown error occurred, Please try again';

    final statusCode = response.statusCode;
    final errorMessage = response.data?['message'];

    if (errorMessage != null && errorMessage is String) {
      return errorMessage;
    }

    switch (statusCode) {
      case 400:
        return 'Bad request, please check your request';
      case 401:
        return 'Unauthorized, please check your credentials';
      case 403:
        return 'Forbidden, you do not have permission';
      case 404:
        return 'The requested resource was not found';
      case 429:
        return 'Too many requests, please try again later';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway, server received an invalid response';
      case 503:
        return 'Service unavailable, server is temporarily down';
      case 504:
        return 'Gateway timeout, server is not responding';
      default:
        return 'Oops! Something went wrong, try again later';
    }
  }

  @override
  String toString() => message;
}
