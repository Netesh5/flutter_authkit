// ignore_for_file: constant_identifier_names

enum RequestType {
  GET(requestType: 'GET'),
  POST(requestType: 'POST'),
  PUT(requestType: 'PUT'),
  DELETE(requestType: 'DELETE');

  final String requestType;

  const RequestType({required this.requestType});
}
