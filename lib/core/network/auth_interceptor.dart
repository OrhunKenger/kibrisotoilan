import 'package:dio/dio.dart';
import '../../data/datasources/auth_local_data_source.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource authLocalDataSource;
  final void Function()? onUnauthorized;

  AuthInterceptor({
    required this.authLocalDataSource,
    this.onUnauthorized,
  });

  static const _noAuthPaths = ['/auth/token', '/auth/register'];

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (_noAuthPaths.contains(options.path)) {
      return super.onRequest(options, handler);
    }

    try {
      final token = await authLocalDataSource.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Storage read failed, proceed without auth header
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        await authLocalDataSource.deleteToken();
      } catch (_) {}
      onUnauthorized?.call();
    }
    super.onError(err, handler);
  }
}
