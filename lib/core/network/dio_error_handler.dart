import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

class DioErrorHandler {
  static Never handle(DioException e) {
    if (_isNetworkError(e)) {
      throw NetworkException(message: 'Sunucuya bağlanılamıyor');
    }
    if (e.response?.statusCode == 401) {
      throw UnauthorizedException();
    }
    throw ServerException(
      message: extractErrorMessage(e),
      statusCode: e.response?.statusCode,
      responseBody: e.response?.data,
    );
  }

  static bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        (e.type == DioExceptionType.unknown && e.response == null);
  }

  static String extractErrorMessage(DioException e) {
    final detail = e.response?.data;
    if (detail is Map && detail.containsKey('detail')) {
      final d = detail['detail'];
      if (d is String) return d;
      if (d is List && d.isNotEmpty) return d.first['msg'] ?? 'Sunucu hatası';
    }
    return e.message ?? 'Sunucu hatası';
  }
}
