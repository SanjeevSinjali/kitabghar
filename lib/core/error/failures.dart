abstract class Failure {
  final String message;
  const Failure(this.message);
}

class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

class ApiFailure extends Failure {
  const ApiFailure({required String message}) : super(message);
}