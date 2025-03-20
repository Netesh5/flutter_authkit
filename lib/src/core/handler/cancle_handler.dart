class CancleHandler extends Failure {
  const CancleHandler() : super(message: "Cancelled by user");
}

sealed class Failure {
  final String message;
  const Failure({required this.message});
}
