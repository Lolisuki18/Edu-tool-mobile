/// Standard API response wrapper matching the backend's `BaseResponse<T>`.
///
/// Every API returns this shape:
/// ```json
/// { "isSuccess": true, "code": 200, "message": "...", "data": ..., "errors": [], "timestamp": "..." }
/// ```
class BaseResponse<T> {
  final bool isSuccess;
  final int code;
  final String message;
  final T? data;
  final List<String> errors;
  final String? timestamp;

  const BaseResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    this.data,
    this.errors = const [],
    this.timestamp,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    // BE có thể trả về "isSuccess" hoặc "success"
    final isSuccess =
        json['isSuccess'] as bool? ?? json['success'] as bool? ?? false;
    return BaseResponse<T>(
      isSuccess: isSuccess,
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors:
          (json['errors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      timestamp: json['timestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value)? toJsonT) {
    return {
      'isSuccess': isSuccess,
      'code': code,
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
      'errors': errors,
      'timestamp': timestamp,
    };
  }
}

/// Paginated sub-structure inside `data` for list endpoints.
///
/// ```json
/// { "content": [...], "page": { "pageNumber": 0, "pageSize": 10, ... } }
/// ```
class PaginatedData<T> {
  final List<T> content;
  final PageInfo page;

  const PaginatedData({required this.content, required this.page});

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return PaginatedData<T>(
      content:
          (json['content'] as List<dynamic>?)
              ?.map((e) => fromJsonT(e))
              .toList() ??
          const [],
      page: PageInfo.fromJson(json['page'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class PageInfo {
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;

  const PageInfo({
    this.pageNumber = 0,
    this.pageSize = 10,
    this.totalElements = 0,
    this.totalPages = 0,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      pageNumber: json['pageNumber'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 10,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}
