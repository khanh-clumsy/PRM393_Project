import 'dart:convert';

import 'package:dio/dio.dart';

/// Trích xuất thông báo lỗi từ response API (.NET) để hiển thị cho người dùng.
///
/// BE thường trả về:
/// - `{ "message": "..." }` — lỗi nghiệp vụ tiếng Việt
/// - `{ "title": "...", "detail": "..." }` — ProblemDetails
/// - `{ "errors": { "field": ["..."] } }` — validation ModelState
class ApiErrorHelper {
  static const String defaultFallback = 'Đã xảy ra lỗi. Vui lòng thử lại.';

  static const String defaultNetworkFallback =
      'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng và thử lại.';

  /// Entry point dùng chung trong controller: nhận [DioException], [Response], hoặc bất kỳ object nào.
  static String messageFrom(
    dynamic error, {
    String fallback = defaultFallback,
    String? networkFallback,
  }) {
    if (error is DioException) {
      return _fromDioException(
        error,
        fallback: fallback,
        networkFallback: networkFallback ?? defaultNetworkFallback,
      );
    }

    if (error is Response) {
      return extractFromBody(error.data) ?? fallback;
    }

    return fallback;
  }

  /// Trích message trực tiếp từ body response (Map / JSON string / plain text).
  static String? extractFromBody(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      return _extractFromMap(Map<String, dynamic>.from(data));
    }

    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) return null;

      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          return extractFromBody(jsonDecode(trimmed));
        } catch (_) {
          return trimmed;
        }
      }

      return trimmed;
    }

    if (data is List) {
      for (final item in data) {
        final msg = extractFromBody(item);
        if (msg != null && msg.isNotEmpty) return msg;
      }
    }

    return null;
  }

  static String _fromDioException(
    DioException error, {
    required String fallback,
    required String networkFallback,
  }) {
    final fromBody = extractFromBody(error.response?.data);
    if (fromBody != null) return fromBody;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return networkFallback;
      case DioExceptionType.badResponse:
        return _fallbackForStatus(error.response?.statusCode, fallback);
      case DioExceptionType.cancel:
        return 'Yêu cầu đã bị hủy.';
      default:
        break;
    }

    final dioMessage = error.message?.trim();
    if (dioMessage != null && dioMessage.isNotEmpty) {
      return dioMessage;
    }

    return fallback;
  }

  static String _fallbackForStatus(int? statusCode, String fallback) {
    return switch (statusCode) {
      400 => 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.',
      401 => 'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.',
      403 => 'Bạn không có quyền thực hiện thao tác này.',
      404 => 'Không tìm thấy dữ liệu yêu cầu.',
      409 => 'Dữ liệu bị trùng hoặc xung đột. Vui lòng thử lại.',
      500 => 'Máy chủ gặp sự cố. Vui lòng thử lại sau.',
      _ => fallback,
    };
  }

  static String? _extractFromMap(Map<String, dynamic> map) {
    for (final key in ['message', 'detail', 'title', 'error']) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    final errors = map['errors'];
    if (errors is Map) {
      return _joinValidationErrors(Map<String, dynamic>.from(errors));
    }

    return null;
  }

  static String? _joinValidationErrors(Map<String, dynamic> errors) {
    final messages = <String>[];

    for (final entry in errors.entries) {
      final value = entry.value;
      if (value is List) {
        for (final item in value) {
          if (item is String && item.trim().isNotEmpty) {
            messages.add(item.trim());
          }
        }
      } else if (value is String && value.trim().isNotEmpty) {
        messages.add(value.trim());
      }
    }

    if (messages.isEmpty) return null;
    return messages.join('\n');
  }
}
