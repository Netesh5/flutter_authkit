class CancelHandler extends Failure {
  const CancelHandler() : super(message: "Request cancelled by a user");
}

sealed class Failure {
  final String message;
  const Failure({required this.message});
}
