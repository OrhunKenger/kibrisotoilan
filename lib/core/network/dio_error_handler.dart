import 'package:dio/dio.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';

class DioErrorHandler {
  static Never handle(DioException e) {
    if (_isNetworkError(e)) {
      throw NetworkException(message: 'İnternet bağlantınızı kontrol edin.');
    }

    final int? statusCode = e.response?.statusCode;
    final dynamic data = e.response?.data;

    // Özel durum: 401 Unauthorized
    if (statusCode == 401) {
      throw UnauthorizedException();
    }

    // Özel durum: 428 Precondition Required (Örn: Doğrulama kodu gerekli)
    if (statusCode == 428) {
      final String? codeType = e.response?.headers.value('x-verification-required');
      if (codeType != null) {
        throw VerificationRequiredFailure(
          message: extractErrorMessage(e),
          codeType: codeType,
        );
      }
    }

    // Genel Sunucu Hataları
    switch (statusCode) {
      case 400:
        throw ServerException(
          message: extractErrorMessage(e, defaultMessage: 'Geçersiz istek.'),
          statusCode: statusCode,
        );
      case 403:
        throw ServerException(
          message: extractErrorMessage(e, defaultMessage: 'Bu işlem için yetkiniz yok.'),
          statusCode: statusCode,
        );
      case 404:
        throw ServerException(
          message: extractErrorMessage(e, defaultMessage: 'İstenilen kaynak bulunamadı.'),
          statusCode: statusCode,
        );
      case 409:
        throw ServerException(
          message: extractErrorMessage(e, defaultMessage: 'Bir çakışma oluştu (Zaten mevcut olabilir).'),
          statusCode: statusCode,
        );
      case 422:
        throw ServerException(
          message: extractErrorMessage(e, defaultMessage: 'Veri doğrulama hatası.'),
          statusCode: statusCode,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        throw ServerException(
          message: 'Sunucu şu anda hizmet veremiyor. Lütfen daha sonra tekrar deneyin.',
          statusCode: statusCode,
        );
      default:
        throw ServerException(
          message: extractErrorMessage(e),
          statusCode: statusCode,
          responseBody: data,
        );
    }
  }

  static bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.error.toString().contains('SocketException');
  }

  static String extractErrorMessage(DioException e, {String defaultMessage = 'Bir sorun oluştu.'}) {
    try {
      final detail = e.response?.data;
      if (detail == null) return e.message ?? defaultMessage;

      if (detail is Map) {
        if (detail.containsKey('detail')) {
          final d = detail['detail'];
          if (d is String) return d;
          if (d is List && d.isNotEmpty) {
            return d.map((e) => e['msg'] ?? '').join(', ');
          }
        }
        if (detail.containsKey('message')) return detail['message'];
        if (detail.containsKey('error')) return detail['error'];
      } else if (detail is String) {
        return detail;
      }
    } catch (_) {
      return defaultMessage;
    }
    return defaultMessage;
  }
}
