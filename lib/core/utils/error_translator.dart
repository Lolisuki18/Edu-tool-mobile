/// Maps generic backend errors to user-friendly Vietnamese messages.
abstract final class ErrorTranslator {
  /// Extracts field-level errors from the API `errors` object.
  /// The API may return either `Map<String, String>` or `List<String>`.
  static Map<String, String> extractFieldErrors(dynamic errors) {
    if (errors is Map) {
      return errors.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    return {};
  }

  /// Returns a single human-readable message from an API error body.
  static String messageFromResponse(Map<String, dynamic>? body) {
    if (body == null) return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    return body['message'] as String? ?? 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
}
