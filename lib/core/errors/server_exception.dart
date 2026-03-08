/// Exception thrown when the API returns `isSuccess == false`.
class ServerException implements Exception {
  final String message;
  final int code;
  final List<String> errors;

  const ServerException({
    required this.message,
    required this.code,
    this.errors = const [],
  });

  @override
  String toString() => 'ServerException($code): $message';
}
