class CancleHandler extends Failure {
  const CancleHandler() : super(message: "Request cancelled by a user");
}

sealed class Failure {
  final String message;
  const Failure({required this.message});
}
