class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Erreur serveur']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Erreur réseau']);
}
