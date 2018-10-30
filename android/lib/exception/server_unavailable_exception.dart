class ServerUnavailableException implements Exception {
  String message;

  ServerUnavailableException(this.message);
}