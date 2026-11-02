abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Erreur serveur']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Erreur de connexion réseau']) : super(message);
}
