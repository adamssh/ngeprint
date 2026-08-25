class AppException implements Exception {
  const AppException(this.userMessage, [this.cause]);

  final String userMessage;
  final Object? cause;

  @override
  String toString() => userMessage;
}
